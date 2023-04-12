import requests
import pandas as pd
import json
import re

states = ['California', 'Texas', 'Washington', 'New York', 'Florida']

response_all_states = requests.get(f'https://api.covidtracking.com/v2/states.json') #all state metadata
data = response_all_states.json()['data']

df = pd.json_normalize(data)[['name','state_code','census.population']]
df = df[df['name'].isin(states)].reset_index(drop=True)
print(df)

df_state = pd.DataFrame()

# fetch data for all 5 states
for index,row in df.iterrows():
	state_code = row['state_code'].lower()
	response_state = requests.get(f'https://api.covidtracking.com/v2/states/{state_code}/daily/simple.json') #historic state data
	
	data_state = response_state.json()['data']
	df_state_temp = pd.json_normalize(data_state)[['date','cases.total', 'cases.confirmed', 'tests.pcr.total', 'tests.antibody.encounters.total', 'tests.antigen.encounters.total', 'outcomes.death.total']]
	df_state_temp.insert(loc=1, column="state_code", value=row['state_code'])
	df_state_temp.insert(loc=2, column="state_name", value=row['name'])
	df_state_temp.insert(loc=3, column="population", value=row['census.population'])
	df_state_temp.rename({'cases.total':'Total Cases', 'cases.confirmed': 'Total Confirmed Cases', 'tests.pcr.total': 
		       'Total PCR Tests', 'tests.antibody.encounters.total': 'Total Antibody Tests', 
	       'tests.antigen.encounters.total' : 'Total Antigen Tests', 'outcomes.death.total': 'Total Deaths'},axis=1,inplace = True)
	df_state = df_state.append(df_state_temp)
print(df_state)
        
