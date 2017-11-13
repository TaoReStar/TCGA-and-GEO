try:
	import xml.etree.cElementTree as ET 
except ImportError:
	import xml.etree.ElementTree as ET

import sys
import pandas as pd
import xml.etree.ElementTree as ET
import os


brca="http://tcga.nci/bcr/xml/clinical/brca/2.7"
lihc="http://tcga.nci/bcr/xml/clinical/lihc/2.7"
xsi="http://www.w3.org/2001/XMLSchema-instance"
admin="http://tcga.nci/bcr/xml/administration/2.7"
shared="http://tcga.nci/bcr/xml/shared/2.7"
clin_shared="http://tcga.nci/bcr/xml/clinical/shared/2.7"
chol_lihc_shared="http://tcga.nci/bcr/xml/clinical/shared/chol_lihc/2.7"
shared_stage="http://tcga.nci/bcr/xml/clinical/shared/stage/2.7"
follow_up_v4.0="http://tcga.nci/bcr/xml/clinical/lihc/followup/2.7/4.0"
lihc_nte="http://tcga.nci/bcr/xml/clinical/lihc/shared/new_tumor_event/2.7/1.0"
rad = "http://tcga.nci/bcr/xml/clinical/radiation/2.7"
admin = 'http://tcga.nci/bcr/xml/administration/2.7'
rx="http://tcga.nci/bcr/xml/clinical/pharmaceutical/2.7"
ablation="http://tcga.nci/bcr/xml/clinical/ablation/2.7"
brca_shared="http://tcga.nci/bcr/xml/clinical/brca/shared/2.7"


os.chdir('/lustre1/st01703/GDC/clinical/liver')


cwd = os.getcwd()
ff = os.listdir(".")
drugs = []
fdir = []
drug_names = []
for i in range(1, len(ff)):
	os.chdir(cwd + '/' + ff[i])
	file = [s for s in os.listdir(".") if 'nation' in s]
	tree = ET.parse(file[0])
	root = tree.getroot()
	drug = root[1].find('{' + rx + '}drugs')
	if len(drug) > 0:
		uuid = os.getcwd()
		fdir.append(uuid + "/" + file[0])
		for item in drug:
			a = item.find('{' + rx + '}drug_name')
			drug_names.append(a.text)



drug_names = []
sorafenib = []
coln = []
cell = []
ER = []
HER2 = []
PR = []
TN = []
NegHer2 = ['0', '1+', '2+']
for i in range(0, len(fdir)):
	tree = ET.parse(fdir[i])
	root = tree.getroot()
	drug = root[1].find('.//drug')
	drug = root[1].find('{' + rx + '}drugs')
	Pid = root[1].find('{' + shared + '}bcr_patient_barcode').text
	pr_test = root[1].find('{' + brca_shared + '}breast_carcinoma_progesterone_receptor_status').text
	er_test = root[1].find('{' + brca_shared + '}breast_carcinoma_estrogen_receptor_status').text
	aaa = root[1].find('{' + brca_shared + '}her2_immunohistochemistry_level_result').text
	if aaa in NegHer2:
		her2_test = 'Negative'
	else
		her2_test = 'Positive'
	if pr_test == 'Negative' and er_test == 'Negative' and her2_test == 'Negative':
		TN.append(Pid)
	else
		if pr_test == 'Positive':
			PR.append(Pid)
		if er_test == 'Positive':
			ER.append(Pid)
		if her2_test == 'Positive':
			HER2.append(Pid)


	for item in drug:
		a = item.find('{' + rx + '}drug_name')
		if(a.text in curated_drug):
			for k in item:
				b = k.tag.split("}")[1]
				c = xstr(k.text)
				print c
				coln.append(b)
				cell.append(c)

cell_new = [w.replace('\n                    ', 'NA') for w in cell]
clinical = pd.DataFrame({'tag':coln, 'text':cell_new})
index = [[x]*22 for x in range(1,32)]
index = [item for sublist in index for item in sublist]

df = clinical.pivot(index=index ,columns='tag')['text']

def xstr(s):
	if s is None:
		return 'NA'
	return s





curated_drug = ['SORAFENIB', 'Nexavar', 'Naxavar', 'Sarafenib', 'Sorafinib ( Nexavar)', 'Sorafenib', 'sorafenib', 'HEC.1 - Sorafenib vs Sorafenib plus Doxorubicin']
	

for item in drug:
	a = item.find('{' + rx + '}drug_name')
	if(a.text in curated_drug):
		print item



for i in drug:
	for item in i.findall('{' + rx + '}drug_name'):
		drug_names.append(item.text)


file = [s for s in os.listdir(".") if 'nationwide' in s]
tree = ET.parse(file[0])
root = tree.getroot()
admin = 'http://tcga.nci/bcr/xml/administration/2.7'
rx="http://tcga.nci/bcr/xml/clinical/pharmaceutical/2.7"

for i in range(80, 104):
	item = root[1][i]
	a = item.tag.split("}")[1]
	b = item.text
	print a, '\n', b




drug = root[1].find('{'+rx+'}drugs')

for i in drug[0]:
	print i.tag, i.text

for item in drug[0].findall('{' + rx + '}drug_name'):
	print item.text


for item in root.findall('{'+rx+'}drugs'):
	drug = item.find('{'+ rx + '}drug')
	print drug[0].text


tree = ET.parse('nationwidechildrens.org_clinical.TCGA-LL-A440.xml')
root = tree.getroot()

for item in tree.iter():
	print item.tag

for item in tree.iter(tag='{http://tcga.nci/bcr/xml/administration/2.7}admin'):
	print item.tag, item.attrib

for admin in root.findall('{http://tcga.nci/bcr/xml/administration/2.7}admin'):
	print admin.text

ns = {'admin': 'http://tcga.nci/bcr/xml/administration/2.7'}

for xx in root.findall('admin:xx', ns):
	print xx.text



tree.write(sys.stdout)

