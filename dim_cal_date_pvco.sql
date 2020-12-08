BEGIN TRANSACTION;

DROP TABLE IF EXISTS numbers_small;
CREATE temp TABLE numbers_small (
  number SMALLINT NOT NULL
) DISTSTYLE ALL SORTKEY (number
);
INSERT INTO numbers_small VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

DROP TABLE IF EXISTS numbers;
CREATE temp TABLE numbers (
  number BIGINT NOT NULL
) DISTSTYLE ALL SORTKEY (number
);
INSERT INTO numbers
  SELECT tenthousands.number * 10000 + thousands.number * 1000 + hundreds.number * 100 + tens.number * 10 + ones.number
  FROM numbers_small tenthousands, numbers_small thousands, numbers_small hundreds, numbers_small tens, numbers_small ones
  LIMIT 1000000;

DROP TABLE IF EXISTS avc_testing_ddl.dim_cal_date CASCADE;
CREATE TABLE avc_testing_ddl.dim_cal_date (
  "tk"                          INT4,
  "date"                        DATE,
  "day_of_week"                 FLOAT8,
  "day_of_week_name"            VARCHAR(9),
  "day_of_month"                INT4,
  "day_of_year"                 INT4,
  "week"                        INT4,
  "iso_week"                    INT4,
  "week_start_date"             TIMESTAMP NULL,
  "week_end_date"               TIMESTAMP NULL,
  "month"                       INT4,
  "month_name"                  VARCHAR(9),
  "month_start_date"            TIMESTAMP NULL,
  "month_end_date"              TIMESTAMP NULL,
  "quarter"                     INT4,
  "quarter_name"                VARCHAR(2),
  "quarter_start_date"          TIMESTAMP NULL,
  "quarter_end_date"            TIMESTAMP NULL,
  "half_year"                   INT4,
  "half_year_name"              VARCHAR(2),
  "year"                        INT4,
  "reporting_year"				int4,
  "year_start_date"             TIMESTAMP NULL,
  "year_end_date"               TIMESTAMP NULL,
  "is_weekday"                  boolean,
  "is_weekend"                  boolean,
  "is_business_day"             boolean
) DISTSTYLE ALL SORTKEY (date);

INSERT INTO avc_testing_ddl.dim_cal_date
(TK
  , "date"
  , day_of_week
  , day_of_week_name
  , day_of_month
  , day_of_year
  , week
  , iso_week
  , week_start_date
  , week_end_date
  , "month"
  , month_name
  , month_start_date
  , month_end_date
  , quarter
  , quarter_name
  , quarter_start_date
  , quarter_end_date
  , half_year
  , half_year_name
  , "year"
  , reporting_year
  , year_start_date
  , year_end_date
  , is_weekday
  , is_weekend
)
  SELECT
    bas.TK,
    bas.date,
    bas.day_of_week,
    CASE bas.day_of_week
    WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    WHEN 7 THEN 'Saturday'
    END                           AS day_of_week_name,
    bas.day_of_month,
    bas.day_of_year,
    cast(to_char(dateadd(DAY,1,bas.date),'IW') as int) as week,
    cast(to_char(bas.date,'IW') as int) as iso_week,
    date_trunc('week', bas.date + 1) - 1                              AS Week_start_date, --Sunday is the week begin day
    DATEADD(day, 7 - (CONVERT(INT, bas.day_of_week)), bas.date)       AS week_end_date, -- Saturday is the week end day
    bas.month,
    CASE bas.month
    WHEN 1 THEN 'January'
    WHEN 2 THEN 'February'
    WHEN 3 THEN 'March'
    WHEN 4 THEN 'April'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'June'
    WHEN 7 THEN 'July'
    WHEN 8 THEN 'August'
    WHEN 9 THEN 'September'
    WHEN 10 THEN 'October'
    WHEN 11 THEN 'November'
    WHEN 12 THEN 'December'
    END                                                               AS month_name,
    date_trunc('month', bas.date)                                     AS month_start_date,
    last_day(bas.date)                                                AS month_end_date,
    bas.quarter,
    'Q' + CONVERT(VARCHAR(1), bas.quarter)                            AS quarter_name,
    date_trunc('quarter', bas.date)                                   AS quarter_start_date,
    dateadd('day', -1, date_trunc('quarter', dateadd('quarter', 1, bas.date))) as quarter_end_date,
    bas.half_year,
    'H' + CONVERT(VARCHAR(1), bas.half_year)                          AS half_year_name,
    bas.year,
    DATEPART(year, DATEADD(day, 7 - (CONVERT(INT, bas.day_of_week)), bas.date)) as reporting_year,
    date_trunc('year', bas.date)                                      AS year_start_date,
    DATEADD(day, -1, DATEADD(year, +1, date_trunc('year', bas.date))) AS year_end_date,
    bas.is_weekday,
    bas.is_weekend
  FROM
  /* Start date can be changed here*/
  (SELECT
          CONVERT(INT, TO_CHAR(DATEADD(day, num.number, '1980-01-01'), 'YYYYMMDD')) AS tk,
          CAST(DATEADD(day, num.number, '1980-01-01') AS DATE)                      AS "date",
          DATE_PART(dow, DATEADD(day, num.number, '1980-01-01')) + 1                AS day_of_week,
          DATEPART(day, DATEADD(day, num.number, '1980-01-01'))                     AS day_of_month,
          DATEPART(doy, DATEADD(day, num.number, '1980-01-01'))                     AS day_of_year,
          DATEPART(week, DATEADD(day, num.number, '1980-01-01'))                    AS "week",
          DATEPART(month, DATEADD(day, num.number, '1980-01-01'))                   AS "month",
          DATEPART(quarter, DATEADD(day, num.number, '1980-01-01'))                 AS quarter,
          CASE WHEN DATEPART(qtr, DATEADD(day, num.number, '1980-01-01')) < 3
            THEN 1
          ELSE 2 END                                                                AS half_year,
          DATEPART(year, DATEADD(day, num.number, '1980-01-01'))                    AS "year",
          CASE WHEN DATEPART(dow, DATEADD(day, num.number, '1980-01-01')) IN (0, 6)
            THEN 0
          ELSE 1 END                                                                AS is_weekday,
          CASE WHEN DATEPART(dow, DATEADD(day, num.number, '1980-01-01')) IN (0, 6)
            THEN 1
          ELSE 0 END                                                                AS is_weekend
        FROM (SELECT *
              FROM numbers num
              LIMIT 43829) num --This number is the number of days from start date.
       ) bas;

UPDATE avc_testing_ddl.dim_cal_date
SET is_business_day =
  CASE when is_weekend THEN FALSE
  ELSE TRUE END
;

COMMIT TRANSACTION;
