BEGIN TRANSACTION;

DROP TABLE IF EXISTS numbers_small;
CREATE TABLE numbers_small (
  number SMALLINT NOT NULL
) DISTSTYLE ALL SORTKEY (number
);
INSERT INTO numbers_small VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

DROP TABLE IF EXISTS numbers;
CREATE TABLE numbers (
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
  "day_of_month_name"           VARCHAR(4),
  "day_of_year"                 INT4,
  "day_of_year_name"            VARCHAR(5),
  "week"                        INT4,
  "iso_week"                    INT4,
  "full_week"                   INT4,
  "week_name"                   VARCHAR(4),
  "week_end_date"               TIMESTAMP NULL,
  "week_start_date"             TIMESTAMP NULL,
  "month"                       INT4,
  "month_name"                  VARCHAR(9),
  "month_end_date"              TIMESTAMP NULL,
  "month_start_date"            TIMESTAMP NULL,
  "quarter"                     INT4,
  "quarter_name"                VARCHAR(2),
  "half_year"                   INT4,
  "half_year_name"              VARCHAR(2),
  "year"                        INT4,
  "year_end_date"               TIMESTAMP NULL,
  "year_start_date"             TIMESTAMP NULL,
  "is_weekday"                  boolean,
  "is_weekend"                  boolean,
  "plus_7"                      DATE,
  "plus_14"                     DATE,
  "plus_21"                     DATE,
  "plus_28"                     DATE,
  "plus_35"                     DATE,
  "plus_42"                     DATE,
  "plus_49"                     DATE,
  "plus_56"                     DATE,
  "plus_63"                     DATE,
  "plus_70"                     DATE,
  "plus_77"                     DATE,
  "plus_84"                     DATE,
  "plus_91"                     DATE,
  "minus_7"                     DATE,
  "minus_14"                    DATE,
  "minus_21"                    DATE,
  "minus_28"                    DATE,
  "minus_35"                    DATE,
  "minus_42"                    DATE,
  "minus_49"                    DATE,
  "minus_56"                    DATE,
  "minus_63"                    DATE,
  "minus_70"                    DATE,
  "minus_77"                    DATE,
  "minus_84"                    DATE,
  "minus_91"                    DATE,
  "month_day_name_rank"         INT4,
  "month_day_name_reverse_rank" INT4,
  "us_holiday_identifier"       VARCHAR(30),
  "is_business_day"             boolean
) DISTSTYLE ALL SORTKEY (date);

INSERT INTO avc_testing_ddl.dim_cal_date
(TK
  , "date"
  , day_of_week
  , day_of_week_name
  , day_of_month
  , day_of_month_name
  , day_of_year
  , day_of_year_name
  , week
  , iso_week
  , week_name
  , week_end_date
  , week_start_date
  , "month"
  , month_name
  , month_end_date
  , month_start_date
  , quarter
  , quarter_name
  , half_year
  , half_year_name
  , "year"
  , year_end_date
  , year_start_date
  , is_weekday
  , is_weekend
)
  SELECT
    bas.TK,
    bas.date,
    bas.day_of_week,
    CASE bas.day_of_week
    WHEN 1
      THEN 'Sunday'
    WHEN 2
      THEN 'Monday'
    WHEN 3
      THEN 'Tuesday'
    WHEN 4
      THEN 'Wednesday'
    WHEN 5
      THEN 'Thursday'
    WHEN 6
      THEN 'Friday'
    WHEN 7
      THEN 'Saturday'
    END                                                               AS day_of_week_name,
    bas.day_of_month,
    CONVERT(VARCHAR(2), bas.day_of_month)
    + CASE RIGHT(CONVERT(VARCHAR(2), bas.day_of_month), 1)
      WHEN 1
        THEN CASE WHEN CONVERT(VARCHAR(2), bas.day_of_month) = '11'
          THEN 'th'
             ELSE 'st' END
      WHEN 2
        THEN CASE WHEN CONVERT(VARCHAR(2), bas.day_of_month) = '12'
          THEN 'th'
             ELSE 'nd' END
      WHEN 3
        THEN CASE WHEN CONVERT(VARCHAR(2), bas.day_of_month) = '13'
          THEN 'th'
             ELSE 'rd' END
      WHEN 4
        THEN 'th'
      WHEN 5
        THEN 'th'
      WHEN 6
        THEN 'th'
      WHEN 7
        THEN 'th'
      WHEN 8
        THEN 'th'
      WHEN 9
        THEN 'th'
      WHEN 0
        THEN 'th' END                                                 AS Day_of_month_name,
    bas.day_of_year,
    CONVERT(VARCHAR(3), bas.day_of_year)
    + CASE RIGHT(CONVERT(VARCHAR(2), bas.day_of_year), 1)
      WHEN 1
        THEN CASE WHEN RIGHT(CONVERT(VARCHAR(2), bas.day_of_year), 2) = '11'
          THEN 'th'
             ELSE 'st' END
      WHEN 2
        THEN CASE WHEN RIGHT(CONVERT(VARCHAR(2), bas.day_of_year), 2) = '12'
          THEN 'th'
             ELSE 'nd' END
      WHEN 3
        THEN CASE WHEN RIGHT(CONVERT(VARCHAR(2), bas.day_of_year), 2) = '13'
          THEN 'th'
             ELSE 'rd' END
      WHEN 4
        THEN 'th'
      WHEN 5
        THEN 'th'
      WHEN 6
        THEN 'th'
      WHEN 7
        THEN 'th'
      WHEN 8
        THEN 'th'
      WHEN 9
        THEN 'th'
      WHEN 0
        THEN 'th' END                                                 AS Day_of_year_name,
    cast(to_char(bas.date,'WW') as int) as week,
    cast(to_char(bas.date,'IW') as int) as iso_week,
    CONVERT(VARCHAR(2), bas.week)
    + CASE RIGHT(CONVERT(VARCHAR(2), bas.week), 1)
      WHEN 1
        THEN CASE WHEN CONVERT(VARCHAR(2), bas.week) = '11'
          THEN 'th'
             ELSE 'st' END
      WHEN 2
        THEN CASE WHEN CONVERT(VARCHAR(2), bas.week) = '12'
          THEN 'th'
             ELSE 'nd' END
      WHEN 3
        THEN CASE WHEN CONVERT(VARCHAR(2), bas.week) = '13'
          THEN 'th'
             ELSE 'rd' END
      WHEN 4
        THEN 'th'
      WHEN 5
        THEN 'th'
      WHEN 6
        THEN 'th'
      WHEN 7
        THEN 'th'
      WHEN 8
        THEN 'th'
      WHEN 9
        THEN 'th'
      WHEN 0
        THEN 'th' END                                                 AS Week_name,
    DATEADD(day, 7 - (CONVERT(INT, bas.day_of_week)), bas.date)       AS week_end_date, -- Saturday is the week end day
    date_trunc('week', bas.date) - 1                                  AS Week_start_date, --Sunday is the week begin day
    bas.month,
    CASE bas.month
    WHEN 1
      THEN 'January'
    WHEN 2
      THEN 'February'
    WHEN 3
      THEN 'March'
    WHEN 4
      THEN 'April'
    WHEN 5
      THEN 'May'
    WHEN 6
      THEN 'June'
    WHEN 7
      THEN 'July'
    WHEN 8
      THEN 'August'
    WHEN 9
      THEN 'September'
    WHEN 10
      THEN 'October'
    WHEN 11
      THEN 'November'
    WHEN 12
      THEN 'December'
    END                                                               AS month_name,
    last_day(bas.date)                                                AS month_end_date,
    date_trunc('month', bas.date)                                     AS month_start_date,
    bas.quarter,
    'Q' + CONVERT(VARCHAR(1), bas.quarter)                            AS quarter_name,
    bas.half_year,
    'H' + CONVERT(VARCHAR(1), bas.half_year)                          AS half_year_name,
    bas.year,
    DATEADD(day, -1, DATEADD(year, +1, date_trunc('year', bas.date))) AS year_end_date,
    date_trunc('year', bas.date)                                      AS year_start_date,
    bas.is_weekday,
    bas.is_weekend
  FROM 
  /* Start date can be changed here)
  (SELECT
          CONVERT(INT, TO_CHAR(DATEADD(day, num.number, '1980-01-01'), 'YYYYMMDD')) AS tk,
          CAST(DATEADD(day, num.number, '1980-01-01') AS DATE)                      AS "date",
          DATE_PART(dow, DATEADD(day, num.number, '1980-01-01')) + 1                AS day_of_week,
          DATEPART(day, DATEADD(day, num.number, '1980-01-01'))                     AS day_of_month,
          DATEPART(doy, DATEADD(day, num.number, '1980-01-01'))                     AS day_of_year,
          DATEPART(week, DATEADD(day, num.number, '1980-01-01'))                    AS week,
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
SET plus_7 = DATEADD(day, 7, "date"),
  plus_14  = DATEADD(day, 14, "date"),
  plus_21  = DATEADD(day, 21, "date"),
  plus_28  = DATEADD(day, 28, "date"),
  plus_35  = DATEADD(day, 35, "date"),
  plus_42  = DATEADD(day, 42, "date"),
  plus_49  = DATEADD(day, 49, "date"),
  plus_56  = DATEADD(day, 56, "date"),
  plus_63  = DATEADD(day, 63, "date"),
  plus_70  = DATEADD(day, 70, "date"),
  plus_77  = DATEADD(day, 71, "date"),
  plus_84  = DATEADD(day, 84, "date"),
  plus_91  = DATEADD(day, 91, "date"),
  minus_7  = DATEADD(day, -7, "date"),
  minus_14 = DATEADD(day, -14, "date"),
  minus_21 = DATEADD(day, -21, "date"),
  minus_28 = DATEADD(day, -28, "date"),
  minus_35 = DATEADD(day, -35, "date"),
  minus_42 = DATEADD(day, -42, "date"),
  minus_49 = DATEADD(day, -49, "date"),
  minus_56 = DATEADD(day, -56, "date"),
  minus_63 = DATEADD(day, -63, "date"),
  minus_70 = DATEADD(day, -70, "date"),
  minus_77 = DATEADD(day, -71, "date"),
  minus_84 = DATEADD(day, -84, "date"),
  minus_91 = DATEADD(day, -91, "date")
WHERE "date" < '3499-12-31';

DROP TABLE IF EXISTS tt_month_rank;
CREATE TEMP TABLE tt_month_rank AS
  SELECT
    avc_testing_ddl.dim_cal_date.date,
    ROW_NUMBER()
    OVER (
      PARTITION BY year, month, day_of_week_name
      ORDER BY date )      AS month_day_name_rank,
    ROW_NUMBER()
    OVER (
      PARTITION BY year, month, day_of_week_name
      ORDER BY date DESC ) AS month_day_name_reverse_rank
  FROM avc_testing_ddl.dim_cal_date;

UPDATE avc_testing_ddl.dim_cal_date
SET
  month_day_name_rank           = tt_month_rank.month_day_name_rank
  , month_day_name_reverse_rank = tt_month_rank.month_day_name_reverse_rank
FROM tt_month_rank
WHERE tt_month_rank.date = avc_testing_ddl.dim_cal_date.date;


UPDATE avc_testing_ddl.dim_cal_date
SET "us_holiday_identifier" =
CASE
WHEN month_name = 'January' AND day_of_month = 1
  THEN 'New Years Day'
WHEN month_name = 'May' AND day_of_week_name = 'Monday' AND month_day_name_reverse_rank = 1
  THEN 'Memorial Day'
WHEN month_name = 'July' AND day_of_month = 4
  THEN '4th of July/Independence Day'
WHEN month_name = 'September' AND day_of_week_name = 'Monday' AND month_day_name_rank = 1
  THEN 'Labor Day'
WHEN month_name = 'October' AND day_of_week_name = 'Monday' AND month_day_name_rank = 2
  THEN 'Columbus Day'
WHEN month_name = 'November' AND day_of_month = 11
  THEN 'Veterans Day'
WHEN month_name = 'November' AND day_of_week_name = 'Thursday' AND month_day_name_rank = 4
  THEN 'Thanksgiving'
WHEN month_name = 'December' AND day_of_month = 25
  THEN 'Christmas'
END;


DROP TABLE IF EXISTS tt_full_weeks_per_year;
CREATE TEMPORARY TABLE tt_full_weeks_per_year AS
  WITH days_per_week_per_year AS (
      SELECT
        "year",
        "week",
        count(1) days
      FROM avc_testing_ddl.dim_cal_date
      WHERE "date" BETWEEN '1980-01-01' AND '3000-01-01'
      GROUP BY "year", "week"
  )
  SELECT
    "year",
    "week",
    ROW_NUMBER()
    OVER (
      PARTITION BY "year"
      ORDER BY "week" ) full_week
  FROM days_per_week_per_year
  WHERE days = 7;

UPDATE avc_testing_ddl.dim_cal_date
SET full_week = tt_full_weeks_per_year.full_week
FROM tt_full_weeks_per_year
WHERE tt_full_weeks_per_year."year" = avc_testing_ddl.dim_cal_date."year" AND tt_full_weeks_per_year.week = avc_testing_ddl.dim_cal_date.week;


UPDATE avc_testing_ddl.dim_cal_date
SET is_business_day =
  CASE WHEN "us_holiday_identifier" IS NOT NULL OR is_weekend THEN FALSE
  ELSE TRUE END
;

COMMIT TRANSACTION;
