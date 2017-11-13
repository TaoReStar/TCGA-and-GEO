""" HTML web scratching """
from lxml import html 
import requests
from bs4 import BeautifulSoup
import time
import pandas as pd
import xml.etree.ElementTree as ET

with open('GPL11154.txt') as f:
	ff = f.readlines()

GSE = []
GSE_number = []

for item in ff:
	if "GSE" in item:
		a = item.strip()
		b = a[a.find('GSE'):]
		link = "http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=" + b
		GSE_number.append(b)
		GSE.append(link)

experiment = []
summary = []
title = []

for i in range(1000,2000):
	page = requests.get(GSE[i])
	soup = BeautifulSoup(page.content, 'lxml')
	a = soup.find(string='Experiment type').parent
	b = a.find_next_sibling('td').get_text(" ")
	b = b.encode("utf-8")
	experiment.append(b)
	a = soup.find(string="Summary").parent
	b = a.find_next_sibling('td').get_text(" ")
	b = b.encode("utf-8")
	summary.append(b)
	a = soup.find(string="Title").parent
	b = a.find_next_sibling('td').get_text(" ")
	b = b.encode("utf-8")
	title.append(b)
	time.sleep(1)

data = pd.DataFrame({'GSE Number':GSE_number, 'Experiment':experiment, 'Title': title, 'Summary': summary})
data.to_csv("GPL11154.CSV")


###GSM breast cancer label scratch
from lxml import html 
import requests
from bs4 import BeautifulSoup
import time
import pandas as pd

with open('GSE65216_GSMids.txt') as f:
	ff = f.readlines()

GSM_links = []

for item in gsm:
	a = item.strip()
	link = "http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=" + a
	GSM_links.append(link)

GSM = []
infor = []
for item in GSM_links:
	page = requests.get(item)
	soup = BeautifulSoup(page.content, 'lxml')
	try:
		a = soup.find(string='Characteristics').parent
		b = a.find_next_sibling('td').get_text(" ")
		b = b.encode("utf-8")
		infor.append(b)
		GSM.append(item.split("acc=")[1])
	except:
		pass

data = pd.DataFrame({'GSM number': GSM, 'Information':infor})
data.to_csv("GSE65216_Breast_information.csv")




###KEGG
###db
link = "http://www.genome.jp/dbget-bin/get_linkdb?-t+genes+path:sce01230"
page = requests.get(link)
soup = BeautifulSoup(page.content, 'lxml')
a = soup.find("pre")
b = a.find_all("a")
genes = []
for item in b:
	ccc = item.get_text()
	ccc = ccc.encode("utf-8")
	ccc = ccc.split(":")[1].encode("utf-8")
	genes.append(ccc)
data = pd.DataFrame({'Amino Acids':genes})
data.to_csv("AAMarker.csv")





