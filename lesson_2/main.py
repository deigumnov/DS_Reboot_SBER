from bs4 import BeautifulSoup
from datetime import datetime
from json import loads
from os import mkdir, path, remove, sep
import pandas as pd
from requests import request
from threading import Thread
from time import sleep
from urllib.request import urlretrieve


def get_objects_our_home(offset, limit):
    """
    Gets objects from site наш.дом.рф with status 0 - in building progress

    Parameters
    ----------
    offset : int
        Is used to skip a fixed number of elements in the result
    limit: int
        Limits the number of elements

    Returns
    ----------
    JSON-file with list objects or empty dictionary
    """
    query = f'https://xn--80az8a.xn--d1aqf.xn--p1ai/' \
            f'%D1%81%D0%B5%D1%80%D0%B2%D0%B8%D1%81%D1%8B' \
            f'/api/kn/object?offset={offset}&limit={limit}' \
            f'&sortField=devId.devShortCleanNm&sortType=asc' \
            f'&objStatus=0'
    res = loads(request("GET", query).text)
    if 'data' in res and 'list' in res['data']:
        return res['data']['list']
    else:
        return dict()


def get_object_from_json(data_json):
    """
    Transform objects from json-file to dict

    Parameters
    ----------
    data_json : json-file
        It contains json with objects from site наш.дом.рф

    Returns
    ----------
    Dictionary with same objects as in input-file
    """
    objects = dict()
    field_list = [
        'buildType', 'latitude', 'longitude', 'objAddr', 'objStatus',
        'objCompensFundFlg', 'objFloorMin', 'objElemLivingCnt',
        'objGuarantyEscrowFlg', 'objProblemFlg', 'objCommercNm',
        'objReady100PercDt', 'objSquareLiving', 'rpdRegionCd',
        'problemFlag', 'residentialBuildings', 'objFloorMax', 'pdId'
    ]
    dev_field_list = ['devId', 'fullName', 'shortName']
    def_org_field_list = ['id', 'fullForm', 'shortForm']
    for m in data_json:
        obj_id = m['objId']
        objects[obj_id] = {}
        for f in dev_field_list:
            objects[obj_id]['dev' + f] = m['developer'].get(f, None)
        for f in def_org_field_list:
            objects[obj_id]['devOrg' + f] =\
                m['developer']['orgForm'].get(f, None)
        for f in field_list:
            objects[obj_id][f] = m.get(f, None)
    return objects


def update_object_desc(obj_desc, obj_id):
    """
    Adds some data to object via API

    Parameters
    ----------
    obj_desc : dict
        It consist dict element with some data about object
    obj_id : int
        This is building object id

    Returns
    ----------
    This function updates object with new data
    """
    def object_json_to_dict(desc_json):
        flat = dict()
        field_list = [
            'nameObj', 'region', 'address', 'miniUrl', 'rpdNum',
            'wallMaterialShortDesc', 'objLkFinishTypeDesc',
            'objLkFreePlanDesc', 'objElemParkingCnt',
            'objSquareLiving', 'rpdPdfLink', 'soldOutPerc',
            'rpdIssueDttm', 'objLkClassDesc', 'newBuildingId',
            'objEnergyEffShortDesc', 'objectType', 'objFlatCnt',
            'residentialBuildings', 'isAvailableWantLiveHere',
            'objFloorCnt', 'objFlatSq', 'objInfrstrRampFlg',
            'objNonlivElemCnt', 'objInfrstrObjPrkngCnt',
            'objTransferPlanDt', 'objInfrstrBicycleLaneFlg',
            'conclusion', 'objInfrstrPlaygrndCnt', 'loadDttm',
            'objInfrstrSportGroundCnt', 'nonlivFirstFloor',
            'objInfrstrTrashAreaCnt', 'objLivCeilingHeight',
            'objInfrstrNotObjPrkngCnt', 'objPriceAvg',
            'objInfrstrCurbLoweringFlg', 'objLkSaleDepEmail',
            'objElevatorWheelchairCnt', 'objGreenHouseFlg',
            'objElevatorPassengerCnt', 'objElevatorCargoCnt',
            'generalContractorNm'
        ]
        dev_field_list = [
            'devShortCleanNm', 'devShortNm', 'comissObjCnt', 'devInn',
            'devFullCleanNm', 'problObjCnt', 'buildObjCnt', 'devKpp',
            'regRegionDesc', 'devPhoneNum', 'devSite', 'devEmail',
            'devOgrn', 'devLegalAddr', 'devFactAddr', 'lastRpdId',
            'fundGuarantyFlg', 'devOrgRegRegionCd', 'govFundFlg',
            'objGuarantyEscrowFlg', 'devEmplMainFullNm'
        ]
        for f in field_list:
            flat[f] = desc_json.get(f, None)
        for f in dev_field_list:
            flat['dev' + f] = desc_json['developer'].get(f, None)
            if isinstance(flat.get('dev' + f, None), str):
                flat['dev' + f] = flat.get('dev' + f).replace('\n', '')
        return flat
    query = f'https://xn--80az8a.xn--d1aqf.xn--p1ai/' \
            f'%D1%81%D0%B5%D1%80%D0%B2%D0%B8%D1%81%D1%8B' \
            f'/api/object/{obj_id}'
    res = loads(request("GET", query).text)
    if 'data' in res:
        obj_desc.update(object_json_to_dict(res['data']))


def get_object_images_links(obj_id):
    """
    Gets list of images assigned to current object ID

    Parameters
    ----------
    obj_id : int
        Object ID

    Returns
    ----------
    List of images with building progress
    """
    query = f'https://xn--80az8a.xn--d1aqf.xn--p1ai/' \
            f'сервисы/каталог-новостроек/объект/{obj_id}'
    res = request("GET", query).text
    soup = BeautifulSoup(res, "html.parser")
    json_images = soup.findAll(attrs={"id": "__NEXT_DATA__"})[0]
    try:
        data_json = loads(json_images.getText())['props']
        data_json = data_json['initialState']['kn']['objectCard']
        data_json = data_json['constructionProgress']['shortInfo']
    except KeyError:
        data_json = []
    return [m['src'] + '?filename=' + m['filename'] for m in data_json]


def image_downloader(link, folder):
    """
    It will download https://xn--80az8a.xn--d1aqf.xn--p1ai/api/ext/file/e41db16f-4183-45b4-9a55-673e0baf39fe?
    filename=obj3632_photo2021-08.jpg to folder/obj3632_photo2021-08fe.jpg = its filename + 2 symbols before '?'

    Parameters
    ----------
    link : str
        link to photo {ex.: at function description}
    folder: str
        actual path

    Returns
    ----------
    As a result this function will save image from link to folder
    """
    image_file = \
        folder + \
        link.split('=')[1].split('.')[0] + \
        link.split('?')[0][-2:] + '.' + \
        link.split('=')[1].split('.')[1]
    urlretrieve(link, image_file)


def download_all_images_by_object(obj_id):
    """
    Multi thread downloader of all images by object ID

    Parameters
    ----------
    obj_id : int
        Object ID

    Returns
    ----------
    It will download all images assigned to given ID to folder
    with mask like this images/obj_id/xxx.jpg
    """
    image_threads = []
    for link in get_object_images_links(obj_id):
        images_path = 'images' + sep + str(obj_id)
        imt = Thread(
            target=image_downloader,
            args=(link, images_path + sep)
        )
        image_threads.append(imt)
        if not path.exists(images_path):
            mkdir(images_path)
    for imt in image_threads:
        imt.start()
    for imt in image_threads:
        imt.join()


if __name__ == '__main__':
    # ==================================================================
    # =================== Home task part one: ==========================
    # ==================================================================
    first, step, max_objects = 0, 1000, 12000
    filename = 'data.csv'
    if path.exists(filename):
        remove(filename)
    for i in range(first, max_objects, step):
        all_objects = {}
        start = datetime.now()
        print(f'Start cycle at {start}\nDownloading {i} - {i+step-1}', end=' ')
        new_objects = get_object_from_json(get_objects_our_home(i, step))
        print(f"completed {len(new_objects)} in {datetime.now() - start}")
        if len(new_objects) == 0:
            break
        all_objects.update(new_objects)
        sleep(10)
        start = datetime.now()
        print(f'Data addition started at {start}')
        threads = []
        for obj in all_objects:
            t = Thread(target=update_object_desc, args=(all_objects[obj], obj))
            threads.append(t)
        for t in threads:
            t.start()
        for t in threads:
            t.join()
        print(f'Addition process ends in {datetime.now() - start}')
        df = pd.DataFrame(all_objects).transpose()
        if not path.exists(filename):
            df.to_csv(
                path_or_buf=filename, mode='w', index_label='obj_ID',
                sep='\t', encoding='utf-8'
            )
        else:
            df.to_csv(
                path_or_buf=filename, mode='a', header=False,
                sep='\t', encoding='utf-8'
            )
        print('Waiting 10 secs for next cycle..\n')
        sleep(10)

    # ==================================================================
    # ====================== Load data sample ==========================
    # ==================================================================

    # filename = 'loaded_data.csv'
    # df = pd.read_csv(
    # 	filepath_or_buffer=filename,
    # 	sep='\t',
    # 	encoding='utf-8',
    # 	index_col='obj_ID'
    # )

    # ==================================================================
    # ===== Home task part two : loading images by some object ID ======
    # ==================================================================

    if not path.exists('images'):
        mkdir('images')

    object_id = 3632
    start = datetime.now()
    print(f'Start downloading images for object {object_id}'
          f' at {start} ', end='')
    download_all_images_by_object(object_id)
    print(f'process ended in {datetime.now() - start}')
