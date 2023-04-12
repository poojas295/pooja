# -*- coding: utf-8 -*-
"""cap_pro_api.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1-Du5WVnkKKMh9tIgapNpAnWwyMOz9iPp

importing required libraries
"""

import requests
import json
from pandas import json_normalize
import pandas as pd

"""loading data into variables from given website and displaying the data (state-wise)"""

#data of the state 'CA'
response_ca=requests.get('https://api.covidtracking.com/v2/states/ca/daily/simple.json')

data=response_ca.json()
data = data['data']
data = json.dumps(data)
dict1 = json.loads(data)
df2 = json_normalize(dict1)

df2.head()

#data of the state 'TX'
response_tx=requests.get('https://api.covidtracking.com/v2/states/tx/daily/simple.json')

data=response_tx.json()
data = data['data']
data = json.dumps(data)
dict2 = json.loads(data)
df3 = json_normalize(dict2)

df3.head()

#data of the state 'WA'
response_wa=requests.get('https://api.covidtracking.com/v2/states/wa/daily/simple.json')

data=response_wa.json()
data = data['data']
data = json.dumps(data)
dict3 = json.loads(data)
df4 = json_normalize(dict3)

df4.head()

#data of the state 'NY'
response_ny=requests.get('https://api.covidtracking.com/v2/states/ny/daily/simple.json')

data=response_ny.json()
data = data['data']
data = json.dumps(data)
dict4 = json.loads(data)
df5 = json_normalize(dict4)

df5.head()

#data of the state 'FL'
response_fl=requests.get('https://api.covidtracking.com/v2/states/fl/daily/simple.json')

data=response_fl.json()
data = data['data']
data = json.dumps(data)
dict5 = json.loads(data)
df6 = json_normalize(dict5)

df6.head(10)

"""converting the data into dataframes"""

dfc=pd.DataFrame(df2, columns=['date', 'state','cases.total','cases.confirmed','tests.pcr.total', 'tests.antibody.encounters.total','tests.antigen.encoutners.total','outcomes.death.total' ])

dft=pd.DataFrame(df3, columns=['date', 'state','cases.total','cases.confirmed','tests.pcr.total', 'tests.antibody.encounters.total','tests.antigen.encoutners.total','outcomes.death.total' ])

dft

dfw=pd.DataFrame(df4, columns=['date', 'state','cases.total','cases.confirmed','tests.pcr.total', 'tests.antibody.encounters.total','tests.antigen.encoutners.total','outcomes.death.total' ])

dfn=pd.DataFrame(df5, columns=['date', 'state','cases.total','cases.confirmed','tests.pcr.total', 'tests.antibody.encounters.total','tests.antigen.encoutners.total','outcomes.death.total' ])

dff=pd.DataFrame(df6, columns=['date', 'state','cases.total','cases.confirmed','tests.pcr.total', 'tests.antibody.encounters.total','tests.antigen.encoutners.total','outcomes.death.total' ])

response1= requests.get('https://api.covidtracking.com/v2/states.json')

data=response1.json()

data=data['data']

data=json.dumps(data)

dictm=json.loads(data)

dfm=json_normalize(dictm)

dfm.head(10)

"""concatenating the data of the states CA, TX, FL, NY, WA and displaying them"""

concat_data = pd.concat([dfc, dft, dff, dfn, dfw], ignore_index=True)

concat_data.head()

concat_data= concat_data.rename(columns={'state': 'state_code'})

"""perform merging operation on the 'state_code' column"""

datafinal=pd.merge( dfm,concat_data, how='inner', on='state_code')

datafinal.head()

"""Columns in FL state table"""

x =df6
x.columns

"""extracting data as on 2nd March,2021 for Florida from table (summary of Florida)"""

datafinal[(datafinal['date']=='2021-03-02')&(datafinal['state_code']=='FL')]

"""extracting data as on 5th March,2021 for California from table (summary of California)"""

datafinal[(datafinal['date']=='2021-03-05')&(datafinal['state_code']=='CA')]

"""extracting data of state Texas (summary of Texas)"""

x = dfm[dfm['state_code']=='TX']

x

"""Rank of the state according to API"""

x = dfm.sort_values(['census.population'], ascending=[False])
x

"""**Calculation of Mortality Rate**"""

datafinal['date']= pd.to_datetime(datafinal['date'])

from datetime import datetime as dt

datafinal['month'] = datafinal['date'].dt.month
datafinal['year'] = datafinal['date'].dt.year

final = datafinal.groupby(['state_code','year','month'],as_index =False)['outcomes.death.total','census.population'].sum()

final

"""report mortality rate for each state, each month"""

final['Mortality rate%'] = (final['outcomes.death.total']/final['census.population'])*100

pd.set_option('display.max_rows',500)
final

""" mortality rate of New York in the month of April, 2020"""

x = final[(final['state_code']=="NY")& (final['year']==2020) & (final['month']==4)]
x

"""happiest state situation in terms of mortality rate in the month of June, 2020"""

x = final[(final['year']==2020) & (final['month']==6)]
x

