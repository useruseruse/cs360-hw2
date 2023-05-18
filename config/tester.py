from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.select import Select
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import StaleElementReferenceException

from math import ceil
import string
import random
import pymysql
timeout = 4
def rand_string():
    letters_set = string.ascii_lowercase + string.digits + string.ascii_uppercase
    code = ''.join([random.choice(letters_set) for _ in range(64)])
    return code
def get_conn():
    return pymysql.connect(host='db', user='dbuser', password='dbuser1234', db='HW', charset='utf8')

def run():
    options = Options()
    options.add_argument("--disable-gpu")
    options.add_argument("--log-level=3")
    options.add_argument('--no-sandbox')
    options.add_argument('--headless')
    options.add_experimental_option('excludeSwitches', ['enable-logging'])
    options.binary_location='/usr/lib/chromium/chrome'
    service = Service('chromedriver')
    driver = webdriver.Chrome(service=service, options=options)

    class WAIT_COLOR_CHECK(object):
        def __init__(self, locator, number):
            self.locator = locator
            self.number = number

        def __call__(self, driver):
            try:
                element = driver.find_element(*self.locator)
                number = len(element.find_elements(By.TAG_NAME, 'tr'))
                return number == self.number
            except StaleElementReferenceException as e:
                return False
            except Exception as e:
                return False
            
    class SCHE_CHECK(object):
        def __init__(self, number, userid):
            self.number = number
            self.userid = userid

        def __call__(self, driver):
            try:
                return schedule_length(self.userid) == self.number
            except StaleElementReferenceException as e:
                return False
            except Exception as e:
                return False
            
    def test_login_forward(success=True):
        driver.get("http://localhost:8080/") 
        return ('login' in driver.current_url) == success

    def test_login_test(userid, userpass, success=False):
        driver.get("http://localhost:8080/login.jsp") 
        driver.find_element(By.NAME, 'id').send_keys(userid)
        driver.find_element(By.NAME, 'password').send_keys(userpass)
        driver.find_element(By.XPATH, "/html/body/form/label/label/input[2]").click()
        return ('login' not in driver.current_url) == success

    def test_register_test(userid, userpass, success=True):
        driver.get("http://localhost:8080/register.jsp") 
        driver.find_element(By.NAME, 'id').send_keys(userid)
        driver.find_element(By.NAME, 'password').send_keys(userpass)
        driver.find_element(By.XPATH, "/html/body/form/label/label/input[2]").click()
        return ('register' not in driver.current_url) == success

    def is_hashed_test(userid, userpass):
        cursor = get_conn().cursor()
        sql = f"SELECT * FROM user WHERE user_id='{userid}'";
        result = cursor.execute(sql)
        if result == 1:
            count = 0
            for _, pw in cursor.fetchall():
                if pw == userpass:
                    cursor.close()
                    return False
                count += 1
            if count != 1:
                cursor.close()
                return False  
            cursor.close()
            return True
        cursor.close()
        return False

        
    def schedule_length(userid):
        cursor = get_conn().cursor()
        sql = f"SELECT COUNT(*) FROM schedule WHERE user_id='{userid}'";
        result = cursor.execute(sql)
        if 0 < result:
            return cursor.fetchone()[0]
        return False

    def ajax_start():
        driver.get("http://localhost:8080/")
        code = rand_string()
        js = """
            var meta = document.createElement('meta');
            meta.id = "ajaxcheck";
            meta.content = "%s";
            document.getElementsByTagName('head')[0].appendChild(meta);
        """ % (code)
        driver.execute_script(js)

        return code

    def ajax_end(verify):
        try:
            driver.find_element(By.ID, 'ajaxcheck')
        except Exception as e:
            return False
        return driver.find_element(By.ID, 'ajaxcheck').get_attribute('content') == verify

    def schedule_insert(schedule, userid):
        _, name, start, end, dow = schedule
        name_elem = driver.find_element(By.XPATH, '/html/body/input[2]')
        name_elem.clear()
        name_elem.send_keys(name)
        start_elem = driver.find_element(By.XPATH, '/html/body/input[3]')
        start_elem.clear()
        start_elem.send_keys(start)
        end_elem = driver.find_element(By.XPATH, '/html/body/input[4]')
        end_elem.clear()
        end_elem.send_keys(end)
        dow_elem = Select(driver.find_element(By.XPATH, '//*[@id="dow"]'))
        dow_elem.select_by_value(dow)
        before = schedule_length(userid)
        driver.find_element(By.XPATH, '/html/body/button').click()
        xpath = f'/html/body/table/tbody'
        try:
            wait = WebDriverWait(driver, timeout)
            wait.until(WAIT_COLOR_CHECK((By.XPATH, xpath), before+1))
        except Exception as e:
            return False
        return schedule_length(userid) == before + 1
    
    def schedule_search(searchInput, before, after):
        xpath = f'/html/body/table/tbody'
        try:
            searchElem = driver.find_element(By.XPATH, '/html/body/input[1]')
            searchElem.clear()
        except Exception as e:
            return False
        try:
            wait = WebDriverWait(driver, timeout)
            wait.until(WAIT_COLOR_CHECK((By.XPATH, xpath), len(before)))
        except Exception as e:
            return False
        if not schedule_check(before):
            return False

        try:
            searchElem = driver.find_element(By.XPATH, '/html/body/input[1]')
            searchElem.send_keys(searchInput)
            searchElem.send_keys(Keys.TAB)
        except Exception as e:
            return False
        try:
            wait = WebDriverWait(driver, timeout)
            wait.until(WAIT_COLOR_CHECK((By.XPATH, xpath), len(after)))
        except Exception as e:
            return False
        if not schedule_check(after):
            return False
        return True

    def schedule_delete(row, before, after, userid):
        if not schedule_check(before):
            return False

        try:
            driver.find_element(By.XPATH, f'/html/body/table/tbody/tr[{row}]/td[1]').click() 
        except Exception as e:
            return False

        try:
            wait = WebDriverWait(driver, timeout)
            wait.until(SCHE_CHECK(len(after), userid))
        except Exception as e:
            return False
        
        if not schedule_check(after):
            return False

        return True

    def schedule_check(schedules):
        xpath = '/html/body/table/tbody'
        try:
            wait = WebDriverWait(driver, timeout)
            wait.until(WAIT_COLOR_CHECK((By.XPATH, xpath), len(schedules)))
        except Exception as e:
            return False
        
        for _ in range(5):
            try:
                table = driver.find_element(By.XPATH, xpath)
                trs = table.find_elements(By.TAG_NAME, 'tr')
                for i, tr in enumerate(trs):
                    for j, td in enumerate(tr.find_elements(By.TAG_NAME, 'td')):
                        text = td.text.strip()
                        if type(schedules[i][j]) == int:
                            text = int(text.split(':')[0])
                        if text != schedules[i][j]:
                            return False
                return True
            except Exception as e:
                driver.implicitly_wait(1)
        return False

    def logout():
        driver.get("http://localhost:8080/logout.jsp") 

    from random import choices, randint
    dow_list = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    dow_list = choices(dow_list, k=4)
    name_list = sorted([rand_string() for _ in range(6)])
    start = [randint(0, 12) for _ in range(4)]
    end = [start[i] + randint(1, 8) for i in range(4)]
    schedule1 = ['1', name_list[0], start[0], end[0], dow_list[0]]
    schedule2 = ['1', name_list[1], start[0], end[0] + 2, dow_list[0]]
    schedule3 = ['2', name_list[2], start[1], end[1], dow_list[1]]
    schedule4 = ['3', name_list[3], start[2], end[2], dow_list[2]]
    schedule5 = ['4', name_list[4], start[2], end[2] + 1, dow_list[2]]
    schedule6 = ['4', name_list[5], start[3], end[3], dow_list[3]]
    schedule7 = ['5', name_list[0], start[0], end[0], dow_list[0]]
    schedule8 = ['6', name_list[0] + '1', start[1], end[1], dow_list[1]]
    schedule9 = ['7', name_list[0] + '12', start[2], end[2], dow_list[2]]
    user1 = [rand_string(), rand_string()]
    user2 = [rand_string(), rand_string()]
    user3 = [rand_string(), rand_string()]
    user4 = [rand_string(), rand_string()]

    test_packages = []
    driver.get("http://localhost:8080/db_init.jsp") 
    try:
        # 1
        test_packages.append(test_login_forward())
    except Exception as e:
        test_packages.append(False)
    try:
        # 2
        test_packages.append(test_login_test(user1[0], user1[1]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 3
        test_packages.append(test_register_test(user1[0], user1[1]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 4
        test_packages.append(test_register_test(user1[0], user1[1], success=False))
    except Exception as e:
        test_packages.append(False)
    try:
        # 5
        test_packages.append(is_hashed_test(user1[0], user1[1]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 6
        test_packages.append(test_login_forward())
    except Exception as e:
        test_packages.append(False)
    try:
        # 7
        test_packages.append(test_login_test(user1[0], user2[1], success=False))
    except Exception as e:
        test_packages.append(False)
    try:
        # 8
        test_packages.append(test_login_test(user1[0], user1[1], success=True))
    except Exception as e:
        test_packages.append(False)
    try:
        # 9
        test_packages.append(test_login_forward(success=False))
    except Exception as e:
        test_packages.append(False)
    code = ajax_start()
    try:
        # 10
        test_packages.append(schedule_insert(schedule1, user1[0]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 11
        test_packages.append(schedule_check([schedule1]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 12
        test_packages.append(schedule_insert(schedule2, user1[0]) == False)
    except Exception as e:
        test_packages.append(False)
    try:
        # 13
        test_packages.append(schedule_check([schedule1]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 14
        test_packages.append(schedule_insert(schedule3, user1[0]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 15
        test_packages.append(schedule_check([schedule1, schedule3]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 16
        test_packages.append(schedule_delete(1, [schedule1, schedule3], [schedule3], user1[0]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 17
        test_packages.append(schedule_check([schedule3]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 18
        test_packages.append(ajax_end(code))
    except Exception as e:
        test_packages.append(False)
    driver.get("http://localhost:8080") 
    try:
        # 19
        test_packages.append(schedule_check([schedule3]))
    except Exception as e:
        test_packages.append(False)
    logout()
    try:
        # 20
        test_packages.append(test_register_test(user3[0], user3[1]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 21
        test_packages.append(test_login_test(user3[0], user3[1], success=True))
    except Exception as e:
        test_packages.append(False)
    try:
        # 22
        test_packages.append(test_login_forward(success=False))
    except Exception as e:
        test_packages.append(False)
    code = ajax_start()
    try:
        # 23
        test_packages.append(schedule_insert(schedule4, user3[0]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 24
        test_packages.append(schedule_check([schedule4]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 25
        test_packages.append(schedule_insert(schedule5, user3[0]) == False)
    except Exception as e:
        test_packages.append(False)
    try:
        # 26
        test_packages.append(schedule_check([schedule4]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 27
        test_packages.append(schedule_insert(schedule6, user3[0]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 28
        test_packages.append(schedule_check([schedule4, schedule6]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 29
        test_packages.append(schedule_delete(2, [schedule4, schedule6], [schedule4], user3[0]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 30
        test_packages.append(schedule_check([schedule4]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 31
        test_packages.append(ajax_end(code))
    except Exception as e:
        test_packages.append(False)
    driver.get("http://localhost:8080") 
    try:
        # 32
        test_packages.append(schedule_check([schedule4]))
    except Exception as e:
        test_packages.append(False)
    logout()
    try:
        # 33
        test_packages.append(test_register_test(user4[0], user4[1]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 34
        test_packages.append(test_login_test(user4[0], user4[1], success=True))
    except Exception as e:
        test_packages.append(False)
    try:
        # 35
        test_packages.append(test_login_forward(success=False))
    except Exception as e:
        test_packages.append(False)
    code = ajax_start()
    try:
        # 36
        test_packages.append(schedule_insert(schedule7, user4[0]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 37
        test_packages.append(schedule_check([schedule7]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 38
        test_packages.append(schedule_insert(schedule8, user4[0]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 39
        test_packages.append(schedule_check([schedule7, schedule8]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 40
        test_packages.append(schedule_insert(schedule9, user4[0]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 41
        test_packages.append(schedule_check([schedule7, schedule8, schedule9]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 42
        test_packages.append(schedule_search(schedule7[1], [schedule7, schedule8, schedule9], [schedule7, schedule8, schedule9]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 43
        test_packages.append(schedule_search(schedule8[1], [schedule7, schedule8, schedule9], [schedule8, schedule9]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 44
        test_packages.append(schedule_search(schedule9[1], [schedule7, schedule8, schedule9], [schedule9]))
    except Exception as e:
        test_packages.append(False)
    try:
        # 45
        test_packages.append(ajax_end(code))
    except Exception as e:
        test_packages.append(False)
    score = ceil(sum([1 for i in test_packages if i]) * 100 / len(test_packages))
    result = [str(i+1) for i, j in enumerate(test_packages) if not j]
    print(score)
    print(' '.join(result))
    driver.quit()
run()