import numpy as np
import pandas as pd
import pickle
from datetime import datetime
from sklearn.model_selection import train_test_split
from scipy import stats
from tqdm import tqdm
from datetime import date
from sklearn.impute import SimpleImputer
from feature_engine.categorical_encoders import OneHotCategoricalEncoder

def initial_processing():
    df = pd.read_csv('2.SQL_Output/venture1_public_organizations.csv')
    print('Initial DF shape: ', df.shape)
    return df

def initial_processing2():
    cats = pd.read_csv('../00.Raw_dataset/category-groups-10-25-2019.csv')
    print('Loaded category group csv')
    return cats

def remove_duplicates(df):
    df.drop_duplicates(subset='name', keep='first', inplace=True)
    return df

def remove_na(df):
    print('Dropping rows with NAs:')
    columns_to_clean_na = ['name', 'country_code', 'founded_on', 'category_groups_list', 'status', 'primary_role']

    for col in columns_to_clean_na:
        try:
            print('NAs in ' + col + ' column = ' + str(df[col].isnull().value_counts()[1]))
        except:
            KeyError
        df = df[pd.notnull(df[col])]
    return df

def column_dropper(df):
    df_mask = df[df['roles'] == 'company']
    columns_to_drop = ['uuid',
                       'short_description',
                       'cb_url',
                       'facebook_url',
                       'twitter_url',
                       'linkedin_url',
                       'profile_image',
                       'domain',
                       'logo_url',
                       'email',
                       'num_exits',
                       'city',
                       'address',
                       'permalink',
                       'created_at',
                       'updated_at',
                       'postal_code',
                       'total_funding_currency_code',
                       'total_funding',
                       'homepage_url',
                       'phone',
                       'alias1',
                       'alias2',
                       'alias3',
                       'type',
                       'name',
                       'roles',
                       'region',
                       ]
    for col in df_mask:
        if col in columns_to_drop:
            df_mask.drop(columns=col, inplace=True)
    for col in df_mask:
        if col.endswith(('Precision')):
            df_mask.drop(columns=col, inplace=True)
    for col in df_mask:
        if col.endswith(('Currency')):
            df_mask.drop(columns=col, inplace=True)
    return df_mask

def date_parser(df):
    date_cols = [x for x in df.columns if x.endswith('date') or x.endswith('on') and not x.endswith('region')]
    for col in date_cols:
        print(col)
        df[col] = df[col].apply(lambda x: pd.to_datetime(str(x), yearfirst=True, errors='coerce'))
    return df

def years_between(d1, d2):
    years = round((d2 - d1).days / 365, 1)
    return years

def Age_at_each_round(df):
    funding_round_datecols = [x for x in df.columns if x.endswith('date') and not x.startswith('age_at_')]
    funding_round_datecols = list(funding_round_datecols)
    founded = df['founded_on']

    for col in funding_round_datecols:
        newlist = []
        print(col)
        for founded_date, interest in zip(founded, df[col]):
            if not pd.isnull(interest):
                newlist.append(years_between(founded_date, interest))
            else:
                newlist.append(np.nan)
        df['age_at_' + col] = newlist
    return df

def Age_at_first_funding(df):
    funding_round_datecols = [x for x in df.columns if x.endswith('date') and x.startswith('age_at_')]
    funding_round_datecols = list(funding_round_datecols)
    df['age_first_funding'] = df[funding_round_datecols].min(axis=1)
    return df

def Age_at_event(df, event_col, new_col_name):
    founded = df['founded_on']
    newlist = []
    df['current_datetime'] = datetime.now()

    for founded_date, event in zip(founded, df[event_col]):
        if not pd.isnull(event):
            newlist.append(years_between(founded_date, event))
        else:
            newlist.append(np.nan)
    df[new_col_name] = newlist
    df = df.drop(columns='current_datetime')
    return df

def renamer(cats, df):
    cats.rename(columns = {'Category Group Name' : 'categories_48',
                       'Categories':'categories_742',
                       'Jak altered':'categories_20'}, inplace=True)
    df.rename(columns = {'category_list':'category_list_742',
                     'category_groups_list':'category_groups_list_46'}, inplace=True)
    return df

def row_string_to_list(df, column):
    df[column] = [x.split(",") for x in df[column]]
    return df

def simplify_46_to_20(df):
    dictionary_new_category = {key:value for (key,value) in zip(cats.categories_48, cats.categories_20)}
    new_20_category_column = []
    for old_list_46 in df['category_groups_list_46']:
        new_list_20 = []
        for old_category in old_list_46:
            try:
                new_list_20.append(dictionary_new_category[old_category])
            except KeyError:
                continue
        new_20_category_column.append(new_list_20)
    df['category_groups_list_20'] = new_20_category_column
    return df

def category_appearances(df, categories_col):
    empty_counter = []
    for row in df[categories_col]:
        for category in row:
            empty_counter.append(category)
    appearance_dict = dict([[x,empty_counter.count(x)] for x in set(empty_counter)])
    return appearance_dict
    return df

def simplify_multiple_categories_to_mode(df, old_col, simplified_col):
    dict_appearances = category_appearances(df, old_col)
    final_column = []
    for row in df[old_col]:
        mode = []
        if len(set(row)) == len(row): #unique check. if they're unique we take the least common (use our counter for this)
            rarest_in_set = min((dict_appearances[x] for x in row))
            for category, num_appearances in dict_appearances.items():
                if num_appearances == rarest_in_set: #it always will be, just chooses the correct one (we are basically doing key value pair here)
                    mode.append(category)
        else: #take the mode of the row
            row_mode = max(set(row), key = row.count)
            mode.append(row_mode)
        final_column.append(mode)
    df[simplified_col] = final_column
    df[simplified_col] = [item for sublist in df[simplified_col] for item in sublist] #just stops them being lists..
    df.drop(columns = old_col, inplace=True)
    return df

def tech_classification(df, col):
    cats.tech.fillna('None_tech', inplace=True) #just becase we had some na's
    row_string_to_list(cats, 'tech')
    list_tech = tuple(cats.tech)
    tech_set = set([item for sublist in list_tech for item in sublist]) #make a set of tech classifiers

    is_tech = []
    for row in df[col]:
        if any(tech_word in row for tech_word in tech_set):
            is_tech.append(1.0)
        else: is_tech.append(0.0)
    df['is_tech'] = is_tech
    df.drop(columns = [col], inplace=True)
    return df

def has_legalname(df):
    has_legal_name = [1 if pd.isnull(x) == False else 0 for x in df.legal_name]
    df['legal_name'] = has_legal_name
    return df


if __name__ == '__main__':
    df = initial_processing()
    cats = initial_processing2()
    df = remove_duplicates(df)
    df = remove_na(df)
    df = column_dropper(df)
    df = date_parser(df)
    df = Age_at_each_round(df)
    df = Age_at_first_funding(df)
    df = Age_at_event(df, 'current_datetime', 'current_age')
    df = Age_at_event(df, 'acquired_on', 'age_at_acquisition')
    df = Age_at_event(df, 'ipo_on', 'age_at_IPO')
    df = Age_at_event(df, 'closed_on', 'age_at_closure')
    df = renamer(cats, df)
    df = row_string_to_list(df, 'category_groups_list_46')
    df = row_string_to_list(df, 'category_list_742')
    df = simplify_46_to_20(df)
    df = simplify_multiple_categories_to_mode(df, 'category_groups_list_20', 'category_groups_list_jak')
    df = tech_classification(df, 'category_list_742')
    df = has_legalname(df)

    with open('data_pickle.pickle', 'wb') as file:
        pickle.dump(df, file)
