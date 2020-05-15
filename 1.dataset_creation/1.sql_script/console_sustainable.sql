alter table organizations
add acquired_on text
;

update organizations
set acquired_on = acquisitions.acquired_on
FROM acquisitions
WHERE
organizations.uuid = acquiree_uuid
------------------------------------------------
alter table organizations
add ipo_on text

update organizations
set ipo_on = ipos.went_public_on
from ipos
where organizations.uuid = ipos.org_uuid
-- 170k rows affected

------------------------------------------------
alter table organizations
add investors_per_round int

with calc as (
  -- Any generic query which returns rowid and corresponding calculated values
  select funding_rounds.org_uuid as rowid, avg(funding_rounds.investor_count)  as calculatedvalue from funding_rounds
  where investor_count>0
  group by org_uuid
)
update organizations
set investors_per_round = calc.calculatedvalue
from calc
where organizations.uuid = calc.rowid

-- select avg(funding_rounds.investor_count), org_name  from funding_rounds
-- where investor_count > 1
-- group by org_uuid, org_name


------------------------------------------------
alter table organizations
add investment_per_funding_round int

with calc as (
  -- Any generic query which returns rowid and corresponding calculated values
  select funding_rounds.org_uuid as rowid, avg(funding_rounds.raised_amount_usd)  as calculatedvalue from funding_rounds
  group by org_uuid
)
update organizations
set investment_per_funding_round = calc.calculatedvalue
from calc
where organizations.uuid = calc.rowid


select avg(funding_rounds.raised_amount_usd), org_name from funding_rounds
where raised_amount_usd>0
group by org_uuid, org_name;

------------------------------------------------
alter table funding_rounds add column has_venture int
alter table funding_rounds add column has_seed_angel int

update funding_rounds
set has_venture = 1
where funding_rounds.investment_type = 'series_a'
;
update funding_rounds
set has_venture = 1
where funding_rounds.investment_type = 'series_b';

update funding_rounds
set has_venture = 1
where funding_rounds.investment_type = 'series_c';

update funding_rounds
set has_seed_angel = 1
where funding_rounds.investment_type = 'angel'

update funding_rounds
set has_seed_angel = 1
where funding_rounds.investment_type = 'seed'

update funding_rounds
set has_seed_angel = 1
where funding_rounds.investment_type = 'pre_seed'

------------------------------------------------
alter table funding_rounds add column is_series_a int
alter table funding_rounds add column is_series_b int
alter table funding_rounds add column is_series_c int
alter table funding_rounds add column is_angel int
alter table funding_rounds add column is_pre_seed int
alter table funding_rounds add column is_seed int

update funding_rounds
set is_series_a = 1
where funding_rounds.investment_type = 'series_a'
;
update funding_rounds
set is_series_b = 1
where funding_rounds.investment_type = 'series_b';

update funding_rounds
set is_series_c = 1
where funding_rounds.investment_type = 'series_c';

update funding_rounds
set is_angel = 1
where funding_rounds.investment_type = 'angel'

update funding_rounds
set is_seed = 1
where funding_rounds.investment_type = 'seed'

update funding_rounds
set is_pre_seed= 1
where funding_rounds.investment_type = 'pre_seed'
------------------------------------------------
alter table funding_rounds add column series_a_amount int
alter table funding_rounds add column series_b_amount int
alter table funding_rounds add column series_c_amount int
alter table funding_rounds add column angel_amount int
alter table funding_rounds add column pre_seed_amount int
alter table funding_rounds add column seed_amount int

update funding_rounds
set series_a_amount = raised_amount_usd
where funding_rounds.investment_type = 'series_a'
;
update funding_rounds
set series_b_amount = raised_amount_usd
where funding_rounds.investment_type = 'series_b'

update funding_rounds
set series_c_amount = raised_amount_usd
where funding_rounds.investment_type = 'series_c'

update funding_rounds
set angel_amount = raised_amount_usd
where funding_rounds.investment_type = 'angel'

update funding_rounds
set seed_amount = raised_amount_usd
where funding_rounds.investment_type = 'seed'

update funding_rounds
set pre_seed_amount = raised_amount_usd
where funding_rounds.investment_type = 'pre_seed'
------------------------------------------------
alter table funding_rounds add column series_a_date text
alter table funding_rounds add column series_b_date text
alter table funding_rounds add column series_c_date text
alter table funding_rounds add column angel_date text
alter table funding_rounds add column pre_seed_date text
alter table funding_rounds add column seed_date text

update funding_rounds
set series_a_date= announced_on
where funding_rounds.investment_type = 'series_a'
;
update funding_rounds
set series_b_date = announced_on
where funding_rounds.investment_type = 'series_b'

update funding_rounds
set series_c_date = announced_on
where funding_rounds.investment_type = 'series_c'

update funding_rounds
set angel_date = announced_on
where funding_rounds.investment_type = 'angel'

update funding_rounds
set seed_date = announced_on
where funding_rounds.investment_type = 'seed'

update funding_rounds
set pre_seed_date = announced_on
where funding_rounds.investment_type = 'pre_seed'

------------------------------------------------
alter table organizations add has_series_a int
alter table organizations add series_a_date text
alter table organizations add series_a_amount int

update organizations
set has_series_a = funding_rounds.is_series_a
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'series_a'

update organizations
set series_a_amount = funding_rounds.series_a_amount
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'series_a'

update organizations
set series_a_date = funding_rounds.series_a_date
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'series_a'

---------------------------------------------------

alter table organizations add has_series_b int
alter table organizations add series_b_date text
alter table organizations add series_b_amount int

update organizations
set has_series_b = funding_rounds.is_series_b
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'series_b'

update organizations
set series_b_amount = funding_rounds.series_b_amount
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'series_b'

update organizations
set series_b_date = funding_rounds.series_b_date
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'series_b'

---------------------------------------------------
alter table organizations add has_series_c int
alter table organizations add series_c_date text
alter table organizations add series_c_amount int

update organizations
set has_series_c = funding_rounds.is_series_c
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'series_c'

update organizations
set series_c_amount = funding_rounds.series_c_amount
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'series_c'

update organizations
set series_c_date = funding_rounds.series_c_date
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'series_c'

---------------------------------------------------

alter table organizations add has_angel int
alter table organizations add angel_date text
alter table organizations add angel_amount int

update organizations
set has_angel = funding_rounds.is_angel
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'angel'

update organizations
set angel_amount = funding_rounds.angel_amount
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'angel'

update organizations
set angel_date = funding_rounds.angel_date
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'angel'

---------------------------------------------------
alter table organizations add has_pre_seed int
alter table organizations add pre_seed_date text
alter table organizations add pre_seed_amount int

update organizations
set has_pre_seed = funding_rounds.is_pre_seed
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'pre_seed'

update organizations
set pre_seed_amount = funding_rounds.pre_seed_amount
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'pre_seed'

update organizations
set pre_seed_date = funding_rounds.pre_seed_date
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'pre_seed'

---------------------------------------------------
alter table organizations add has_seed int
alter table organizations add seed_date text
alter table organizations add seed_amount int

update organizations
set has_seed = funding_rounds.is_seed
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'seed'

update organizations
set seed_amount = funding_rounds.seed_amount
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'seed'

update organizations
set seed_date = funding_rounds.seed_date
from funding_rounds
where organizations.uuid = funding_rounds.org_uuid AND investment_type = 'seed'
-------------------

alter table funding_rounds add investor_top500_count int

/*FIRST, create a temporary table of all investments made by the top 500 ivnestors. we do this by selecting the investment, the id, from the intersection of our top 500 investors and their investments*/
CREATE TEMPORARY TABLE top_500_investments AS (select investments.uuid as investment_uuid, investments.name, funding_round_uuid, investor_uuid, investor_name from investments
    inner join investors_500
        on investments.investor_uuid = investors_500.uuid)

/*then we create a temporary table from the amount of times each funding round appears in our top 500 INVESTMENTS.. beacuse ofc we can have that each top500 person invests in multiple rounds..*/

CREATE TEMPORARY TABLE funding_round_investments_from_top500 as (select count(top_500_investments.funding_round_uuid) as total, top_500_investments.funding_round_uuid from top_500_investments group by funding_round_uuid)

/*then we say ok now lets do an inner join on funding rounds and that count.. linking them with funding round iid */

with calc as (
 select * from funding_round_investments_from_top500
)
update funding_rounds
set investor_top500_count = calc.total
from calc
where funding_rounds.uuid = calc.funding_round_uuid

---------------
alter table organizations add top500_investors int

with sums as (
    select sum(funding_rounds.investor_top500_count) as total, funding_rounds.org_uuid
    from funding_rounds
group by funding_rounds.org_uuid
    )

update organizations
set top500_investors = sums.total
from sums
where organizations.uuid = sums.org_uuid

------------------
/*count of acquisitions per company*/
alter table organizations add number_of_acquisitions int

with count_acquisitions as (
    select count(acquisitions.acquirer_uuid) as totals, acquisitions.acquirer_uuid
    from acquisitions
    group by acquisitions.acquirer_uuid)

update organizations
set number_of_acquisitions = count_acquisitions.totals
from count_acquisitions
where uuid = count_acquisitions.acquirer_uuid
--------------------
alter table organizations add total_investments_made int

with total_investments as (
    select count(investments.investor_uuid) as totals, investments.investor_uuid
    from investments
    group by investments.investor_uuid)

update organizations
set total_investments_made = total_investments.totals
from total_investments
where uuid = total_investments.investor_uuid

-----------------------

alter table jobs_modified add is_ceo_founder int

update jobs_modified
    set is_ceo_founder =
        case WHEN jobs_modified.is_ceo = 1 then 1
             WHEN jobs_modified.is_founder =1 then 1
end

-------------------

alter table jobs_modified add gender text

update jobs_modified
set gender = people.gender
from people
where jobs_modified.person_uuid = people.uuid

alter table jobs_modified add linkedin_url text

update jobs_modified
set linkedin_url = people.linkedin_url
from people
where jobs_modified.person_uuid = people.uuid

alter table jobs_modified add has_linkedin int

update jobs_modified
set has_linkedin = 1
where jobs_modified.linkedin_url is not null

---------------------------

alter table jobs_modified add is_male int
alter table jobs_modified add is_female int

update jobs_modified
    set is_male = 1
    where jobs_modified.gender = 'male'

update jobs_modified
    set is_female = 1
    where jobs_modified.gender = 'female'

alter table organizations add number_male_cofound_ceos int
alter table organizations add number_female_cofound_ceos int

with total_male_cofound_ceo as (
    select jobs_modified.org_uuid, sum(jobs_modified.is_male) as total
    from jobs_modified
    where jobs_modified.is_ceo_founder = 1
    group by jobs_modified.org_uuid

)
update organizations
set number_male_cofound_ceos = total_male_cofound_ceo.total
from total_male_cofound_ceo
where organizations.uuid = total_male_cofound_ceo.org_uuid

with total_female_cofound_ceo as (
    select jobs_modified.org_uuid, sum(jobs_modified.is_female) as total
    from jobs_modified
    where jobs_modified.is_ceo_founder = 1
    group by jobs_modified.org_uuid
)
update organizations
set number_female_cofound_ceos = total_female_cofound_ceo.total
from total_female_cofound_ceo
where organizations.uuid = total_female_cofound_ceo.org_uuid


-----------------------

alter table organizations add number_cofounders_CEOs int

with total_founders as (
    select jobs_modified.org_uuid, sum(jobs_modified.is_ceo_founder) as total
    from jobs_modified
    group by jobs_modified.org_uuid
)
update organizations
set number_cofounders_CEOs = total_founders.total
from total_founders
where organizations.uuid = total_founders.org_uuid

------------
alter table organizations add has_founder int

update organizations
    set has_founder =
        case WHEN number_cofounders_CEOs >= 1 then 1.0
             else 0.0
end

---------------
alter table organizations add company_current_experience int

with experience as (
    select jobs_modified.org_uuid, sum(jobs_modified.months_between_col) as total
    from jobs_modified
    where jobs_modified.is_current = 'True'
    group by jobs_modified.org_uuid

)
update organizations set company_current_experience = experience.total
from experience
where organizations.uuid = experience.org_uuid
---------------
alter table organizations add company_current_founder_ceo_experience int

with experience as (
    select jobs_modified.org_uuid, sum(jobs_modified.months_between_col) as total
    from jobs_modified
    where jobs_modified.is_ceo_founder =1 and jobs_modified.is_current = 'True'
    group by jobs_modified.org_uuid
)
update organizations
set company_current_founder_ceo_experience = experience.total
from experience
where organizations.uuid = experience.org_uuid

----------------

with experience as (
    select jobs_modified.org_uuid, sum(jobs_modified.months_between_col) as total
    from jobs_modified
    where jobs_modified.is_ceo_founder =1
    group by jobs_modified.org_uuid
)
update organizations
set company_current_founder_ceo_experience = experience.total
from experience
where organizations.uuid = experience.org_uuid

------------------
alter table organizations add total_current_jobs int

with jobs as (
    select jobs_modified.org_uuid, count(jobs_modified.person_uuid) as total
    from jobs_modified
    where jobs_modified.is_current = 'True'
    group by jobs_modified.org_uuid
)
update organizations
set total_current_jobs = jobs.total
from jobs
where organizations.uuid = jobs.org_uuid
-----------------------------

alter table jobs_modified add total_degrees int

with degree_count as (
    select degrees.person_uuid, count(degrees.person_uuid) as total
    from degrees
    group by degrees.person_uuid
)
update jobs_modified
    set total_degrees = degree_count.total
from degree_count
    where jobs_modified.person_uuid = degree_count.person_uuid

alter table degrees add is_mba int
alter table degrees add has_mba int

update degrees
    set is_mba =1 where degree_type = 'MBA'

with total as (
    select degrees.person_uuid, max(degrees.is_mba) as max -- this will always be one if they have a single MBA
    from degrees
    group by degrees.person_uuid
)
update degrees
    set has_mba = total.max
from total
where degrees.person_uuid = total.person_uuid


alter table jobs_modified add has_mba int

update jobs_modified
    set has_mba = degrees.has_mba
from degrees
    where jobs_modified.person_uuid = degrees.person_uuid



-----------------

alter table organizations add total_degrees_cofound_ceo int
alter table organizations add max_degrees_cofound_ceo int
alter table organizations add total_mbas_cofound_ceo int

with total_degrees as (
    select jobs_modified.org_uuid, sum(jobs_modified.total_degrees) as total
    from jobs_modified
    where is_ceo_founder =1
    group by jobs_modified.org_uuid
)
update organizations
    set total_degrees_cofound_ceo = total_degrees.total
from total_degrees
    where organizations.uuid = total_degrees.org_uuid

with max_degrees as (
    select jobs_modified.org_uuid, max(jobs_modified.total_degrees) as max
    from jobs_modified
    where is_ceo_founder =1
    group by jobs_modified.org_uuid
)
update organizations
    set max_degrees_cofound_ceo = max_degrees.max
from max_degrees
    where organizations.uuid = max_degrees.org_uuid

with total_mba as (
    select jobs_modified.org_uuid, sum(jobs_modified.has_mba) as total
    from jobs_modified
    where is_ceo_founder =1
    group by jobs_modified.org_uuid
)
update organizations
    set total_mbas_cofound_ceo = total_mba.total
from total_mba
    where organizations.uuid = total_mba.org_uuid

-------------------------------

alter table organizations
add has_facebook int

alter table organizations
add has_twitter int

alter table organizations
add has_homepage int

alter table organizations
add has_linkedin int

alter table organizations
add has_email int

alter table organizations
add has_phone int

update organizations
set has_facebook = 1
where facebook_url is not null

update organizations
set has_twitter = 1
where twitter_url is not null

update organizations
set has_homepage = 1
where homepage_url is not null

update organizations
set has_linkedin = 1
where linkedin_url is not null

update organizations
set has_email = 1
where email is not null

update organizations
set has_phone = 1
where phone is not null

---------------------------
alter table organizations
add investors_in_last_round int

with calc as (
  -- Any generic query which returns rowid and corresponding calculated values
  select funding_rounds.org_uuid, funding_rounds.announced_on, sum(funding_rounds.investor_count)  as calculatedvalue from funding_rounds
  where investor_count>0
  group by funding_rounds.org_uuid, funding_rounds.announced_on
)
update organizations
set investors_in_last_round = calc.calculatedvalue
from calc
where organizations.uuid = calc.org_uuid AND organizations.last_funding_on = calc.announced_on

----------------------------
ALTER TABLE final_bcorp_v2
RENAME COLUMN name TO company_name;

CREATE TABLE sustainable_output
  AS (
      SELECT * FROM final_bcorp_v2
      INNER JOIN organizations
      on final_bcorp_v2.company_name = organizations.name)
