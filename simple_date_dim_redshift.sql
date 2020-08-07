/*
Script to create a simple Dat dimension table in Amazon Redshift
*/

CREATE TABLE date_dimension (
  "date_id"               INTEGER                     NOT NULL PRIMARY KEY,
  -- DATE
  "full_date"             DATE                        NOT NULL,
  "au_format_date"        CHAR(10)                    NOT NULL,
  "us_format_date"        CHAR(10)                    NOT NULL,
  -- YEAR
  "year_number"           SMALLINT                    NOT NULL,
  "year_week_number"      SMALLINT                    NOT NULL,
  "year_day_number"       SMALLINT                    NOT NULL,
  "au_fiscal_year_number" SMALLINT                    NOT NULL,
  "us_fiscal_year_number" SMALLINT                    NOT NULL,
  -- QUARTER
  "qtr_number"            SMALLINT                    NOT NULL,
  "au_fiscal_qtr_number"  SMALLINT                    NOT NULL,
  "us_fiscal_qtr_number"  SMALLINT                    NOT NULL,
  -- MONTH
  "month_number"          SMALLINT                    NOT NULL,
  "month_name"            CHAR(9)                     NOT NULL,
  "month_day_number"      SMALLINT                    NOT NULL,
  -- WEEK
  "week_day_number"       SMALLINT                    NOT NULL,
  -- DAY
  "day_name"              CHAR(9)                     NOT NULL,
  "day_is_weekday"        SMALLINT                    NOT NULL,
  "day_is_last_of_month"  SMALLINT                    NOT NULL
) DISTSTYLE ALL SORTKEY (date_id);
And we populate it:


INSERT INTO date_dimension
  SELECT
    cast(seq + 1 AS INTEGER)                                      AS date_id,
-- DATE
    datum                                                         AS full_date,
    TO_CHAR(datum, 'DD/MM/YYYY') :: CHAR(10)                      AS au_format_date,
    TO_CHAR(datum, 'MM/DD/YYYY') :: CHAR(10)                      AS us_format_date,
-- YEAR
    cast(extract(YEAR FROM datum) AS SMALLINT)                    AS year_number,
    cast(extract(WEEK FROM datum) AS SMALLINT)                    AS year_week_number,
    cast(extract(DOY FROM datum) AS SMALLINT)                     AS year_day_number,
    cast(to_char(datum + INTERVAL '6' MONTH, 'yyyy') AS SMALLINT) AS au_fiscal_year_number,
    cast(to_char(datum + INTERVAL '3' MONTH, 'yyyy') AS SMALLINT) AS us_fiscal_year_number,
-- QUARTER
    cast(to_char(datum, 'Q') AS SMALLINT)                         AS qtr_number,
    cast(to_char(datum + INTERVAL '6' MONTH, 'Q') AS SMALLINT)    AS au_fiscal_qtr_number,
    cast(to_char(datum + INTERVAL '3' MONTH, 'Q') AS SMALLINT)    AS us_fiscal_qtr_number,
-- MONTH
    cast(extract(MONTH FROM datum) AS SMALLINT)                   AS month_number,
    to_char(datum, 'Month')                                       AS month_name,
    cast(extract(DAY FROM datum) AS SMALLINT)                     AS month_day_number,
-- WEEK
    cast(to_char(datum, 'D') AS SMALLINT)                         AS week_day_number,
-- DAY
    to_char(datum, 'Day')                                         AS day_name,
    CASE WHEN to_char(datum, 'D') IN ('1', '7')
      THEN 0
    ELSE 1 END                                                    AS day_is_weekday,
    CASE WHEN
      extract(DAY FROM (datum + (1 - extract(DAY FROM datum)) :: INTEGER +
                        INTERVAL '1' MONTH) :: DATE -
                       INTERVAL '1' DAY) = extract(DAY FROM datum)
      THEN 1
    ELSE 0 END                                                    AS day_is_last_of_month
  FROM
    -- Generate days for the next ~20 years starting from 2011.
    (
      SELECT
        '2011-01-01' :: DATE + generate_series AS datum,
        generate_series                        AS seq
      FROM generate_series(0, 20 * 365, 1)
    ) DQ
  ORDER BY 1;
