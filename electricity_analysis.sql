-- ===================================
-- Saudi Electricity Consumption Analysis
-- Dataset: Saudi Arabia Electricity Dataset (Kaggle)
-- Period: 2005 - 2024
-- ===================================

-- إنشاء الجدول
CREATE TABLE electricity (
    id                          INT PRIMARY KEY,
    year                        INT,
    month                       INT,
    region                      VARCHAR(50),
    weather_station_id          INT,
    avg_temperature_c           DECIMAL(5,2),
    subscribers_count           BIGINT,
    generating_capacity_mw      INT,
    industrial_index            DECIMAL(8,2),
    residential_index           DECIMAL(8,2),
    gdp_index                   DECIMAL(8,2),
    fuel_price_index            DECIMAL(5,2),
    solar_output_mwh            DECIMAL(10,2),
    wind_output_mwh             DECIMAL(10,2),
    maintenance_score           DECIMAL(4,2),
    holiday_flag                INT,
    peak_load_mw                INT,
    electricity_consumption_gwh DECIMAL(10,2)
);

-- ===================================
-- 1. متوسط استهلاك الكهرباء لكل منطقة
-- Average Electricity Consumption by Region
-- ===================================
SELECT
    region,
    ROUND(AVG(electricity_consumption_gwh), 2) AS avg_consumption_gwh,
    ROUND(AVG(avg_temperature_c), 1)           AS avg_temp_c,
    COUNT(*)                                    AS records_count
FROM electricity
GROUP BY region
ORDER BY avg_consumption_gwh DESC;

-- ===================================
-- 2. جدولة الصيانة المثلى
-- Optimal Maintenance Scheduling
-- الأشهر ذات الاستهلاك المنخفض = أفضل وقت للصيانة
-- ===================================
SELECT
    month,
    CASE month
        WHEN 1  THEN 'يناير'   WHEN 2  THEN 'فبراير'
        WHEN 3  THEN 'مارس'    WHEN 4  THEN 'أبريل'
        WHEN 5  THEN 'مايو'    WHEN 6  THEN 'يونيو'
        WHEN 7  THEN 'يوليو'   WHEN 8  THEN 'أغسطس'
        WHEN 9  THEN 'سبتمبر'  WHEN 10 THEN 'أكتوبر'
        WHEN 11 THEN 'نوفمبر'  WHEN 12 THEN 'ديسمبر'
    END AS month_name,
    ROUND(AVG(electricity_consumption_gwh), 2) AS avg_consumption_gwh,
    CASE
        WHEN AVG(electricity_consumption_gwh) <
            (SELECT AVG(electricity_consumption_gwh) * 0.85 FROM electricity)
            THEN '✅ مثالي للصيانة'
        WHEN AVG(electricity_consumption_gwh) <=
            (SELECT AVG(electricity_consumption_gwh) FROM electricity)
            THEN '⚠️ صيانة مقبولة'
        ELSE '❌ تجنب الصيانة'
    END AS maintenance_recommendation
FROM electricity
GROUP BY month
ORDER BY avg_consumption_gwh ASC;

-- ===================================
-- 3. الأشهر الحرجة
-- Critical Months
-- ===================================
SELECT
    month,
    CASE month
        WHEN 1  THEN 'يناير'   WHEN 2  THEN 'فبراير'
        WHEN 3  THEN 'مارس'    WHEN 4  THEN 'أبريل'
        WHEN 5  THEN 'مايو'    WHEN 6  THEN 'يونيو'
        WHEN 7  THEN 'يوليو'   WHEN 8  THEN 'أغسطس'
        WHEN 9  THEN 'سبتمبر'  WHEN 10 THEN 'أكتوبر'
        WHEN 11 THEN 'نوفمبر'  WHEN 12 THEN 'ديسمبر'
    END AS month_name,
    ROUND(AVG(electricity_consumption_gwh), 2) AS avg_consumption_gwh,
    ROUND(AVG(peak_load_mw), 0)                AS avg_peak_load_mw,
    CASE
        WHEN AVG(electricity_consumption_gwh) >
            (SELECT AVG(electricity_consumption_gwh) * 1.15 FROM electricity)
            THEN '🚨 شهر حرج'
        WHEN AVG(electricity_consumption_gwh) >=
            (SELECT AVG(electricity_consumption_gwh) FROM electricity)
            THEN '⚠️ شهر مرتفع'
        ELSE '✅ شهر طبيعي'
    END AS consumption_status
FROM electricity
GROUP BY month
ORDER BY avg_consumption_gwh DESC;
