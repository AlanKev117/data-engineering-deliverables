-- create view with xml content parsed as required
create
or replace view dataeng.xp_log_review as
select
  id_review AS log_id,
  xpath('//logDate/text()', log :: xml) AS xp_log_date,
  xpath('//device/text()', log :: xml) AS xp_device,
  xpath('//location/text()', log :: xml) AS xp_location,
  xpath('//os/text()', log :: xml) AS xp_os,
  xpath('//ipAddress/text()', log :: xml) AS xp_ip,
  xpath('//phoneNumber/text()', log :: xml) AS xp_phone_number
from
  dataeng.log_review;

-- create view with xml parsing result cleansed
create
or replace view dataeng.nb_log_review as
select
  log_id,
  substring(
    cast(xp_log_date as varchar(50))
    from
      '{"?([a-zA-Z0-9 .-]*)"?}'
  ) as nb_log_date,
  substring(
    cast(xp_device as varchar(50))
    from
      '{"?([a-zA-Z0-9 .-]*)"?}'
  ) as nb_device,
  substring(
    cast(xp_location as varchar(50))
    from
      '{"?([a-zA-Z0-9 .-]*)"?}'
  ) as nb_location,
  substring(
    cast(xp_os as varchar(50))
    from
      '{"?([a-zA-Z0-9 .-]*)"?}'
  ) as nb_os,
  substring(
    cast(xp_ip as varchar(50))
    from
      '{"?([a-zA-Z0-9 .-]*)"?}'
  ) as nb_ip,
  substring(
    cast(xp_phone_number as varchar(50))
    from
      '{"?([a-zA-Z0-9 .-]*)"?}'
  ) as nb_phone_number
from
  dataeng.xp_log_review;

-- create view with xml parsed and data types properly set
create
or replace view dataeng.dt_log_review as
select
  cast(log_id as int) as log_id,
  to_date(nb_log_date, 'MM-dd-yyyy') as log_date,
  nb_device as device,
  nb_os as os,
  nb_location as location,
  case
    LOWER(nb_os)
    when 'apple ios' then 'safari'
    when 'apple macos' then 'safari'
    when 'google android' then 'chrome'
    when 'linux' then 'firefox'
    when 'microsoft windows' then 'edge'
    else 'chrome'
  end as browser,
  nb_ip as ip,
  nb_phone_number as phone_number
from
  dataeng.nb_log_review;

-- populate fact table
SELECT
  row_number() over (
    order by
      lr.log_date
  ) as id_fact_movie_analytics,
  lr.log_date as id_dim_date,
  case
    lr.location
    WHEN 'Alabama' THEN 'AL'
    WHEN 'Alaska' THEN 'AK'
    WHEN 'Arizona' THEN 'AZ'
    WHEN 'Arkansas' THEN 'AR'
    WHEN 'California' THEN 'CA'
    WHEN 'Colorado' THEN 'CO'
    WHEN 'Connecticut' THEN 'CT'
    WHEN 'Delaware' THEN 'DE'
    WHEN 'Florida' THEN 'FL'
    WHEN 'Georgia' THEN 'GA'
    WHEN 'Hawaii' THEN 'HI'
    WHEN 'Idaho' THEN 'ID'
    WHEN 'Illinois' THEN 'IL'
    WHEN 'Indiana' THEN 'IN'
    WHEN 'Iowa' THEN 'IA'
    WHEN 'Kansas' THEN 'KS'
    WHEN 'Kentucky' THEN 'KY'
    WHEN 'Lousiana' THEN 'LA'
    WHEN 'Maine' THEN 'ME'
    WHEN 'Maryland' THEN 'MD'
    WHEN 'Massachussets' THEN 'MA'
    WHEN 'Michigan' THEN 'MI'
    WHEN 'Minnesota' THEN 'MN'
    WHEN 'Mississippi' THEN 'MS'
    WHEN 'Missouri' THEN 'MO'
    WHEN 'Montana' THEN 'MT'
    WHEN 'Nebraska' THEN 'NE'
    WHEN 'Nevada' THEN 'NV'
    WHEN 'New Hampshire' THEN 'NH'
    WHEN 'New Jersey' THEN 'NJ'
    WHEN 'New Mexico' THEN 'NM'
    WHEN 'New York' THEN 'NY'
    WHEN 'North Carolina' THEN 'NC'
    WHEN 'North Dakota' THEN 'ND'
    WHEN 'Ohio' THEN 'OH'
    WHEN 'Oklahoma' THEN 'OK'
    WHEN 'Oregon' THEN 'OR'
    WHEN 'Pensylvania' THEN 'PA'
    WHEN 'Rhode Island' THEN 'RI'
    WHEN 'South Carolina' THEN 'SC'
    WHEN 'South Dakota' THEN 'SD'
    WHEN 'Tennessee' THEN 'TN'
    WHEN 'Texas' THEN 'TX'
    WHEN 'Utah' THEN 'UT'
    WHEN 'Vermont' THEN 'VT'
    WHEN 'Virginia' THEN 'VA'
    WHEN 'Washington' THEN 'WA'
    WHEN 'West Virginia' THEN 'WV'
    WHEN 'Wisconsin' THEN 'WI'
    WHEN 'Wyoming' THEN 'WY'
  end as id_dim_location,
  concat(
    'd_',
    case
      lr.device
      when 'Mobile' then 'M'
      when 'Computer' then 'C'
      when 'Tablet' then 'T'
    end,
    '_',
    case
      lr.os
      when 'Apple iOS' then 'I'
      when 'Linux' then 'L'
      when 'Apple MacOS' then 'M'
      when 'Google Android' then 'A'
      when 'Microsoft Windows' then 'W'
    end,
    '_',
    case
      lr.browser
      when 'chrome' then 'C'
      when 'edge' then 'E'
      when 'firefox' then 'F'
      when 'safari' then 'S'
    end
  ) as id_dim_device,
  SUM(up.quantity * up.unit_price) as amount_spent,
  SUM(mr.positive_review) as review_score,
  COUNT(mr.review_id) as review_count
FROM
  user_purchase up
  INNER JOIN movie_review mr ON up.customer_id = mr.customer_id
  INNER JOIN log_reviews lr ON mr.review_id = lr.log_id
GROUP BY
  lr.log_date,
  lr.location,
  lr.device,
  lr.os,
  lr.browser