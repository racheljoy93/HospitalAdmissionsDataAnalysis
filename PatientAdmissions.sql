/* Calculate average length of stay for each medical condition. Group by the medical condition and ordered by Average_Length_of_Stay */
SELECT 
    Medical_Condition,
    ROUND(AVG(Discharge_Date - Admit_Date)) AS 'Average_Length_of_Stay'
FROM
    hospitalrecords
GROUP BY Medical_Condition
ORDER BY Average_Length_of_Stay;

/* Show the total admissions by month in the past 2 years */
SELECT 
    DATE_FORMAT(Admit_Date, '%Y-%m') AS 'Month',
    COUNT(*) AS 'Total_Admissions'
FROM
    hospitalrecords
WHERE
    Admit_Date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
GROUP BY Month
ORDER BY Month;

/* Show medical conditions over the average daily admissions */
SELECT 
    Medical_Condition,
    ROUND(AVG(Discharge_Date - Admit_Date)) AS 'Average_Length_of_Stay'
FROM
    hospitalrecords
GROUP BY Medical_Condition
HAVING AVG(Discharge_Date - Admit_Date) > (SELECT 
        AVG(Discharge_Date - Admit_Date)
    FROM
        hospitalrecords)
ORDER BY Average_Length_of_Stay;

/* Year over year trends in patient admissions for the last 4 years */
WITH Medical_Condition_Trends AS(
	SELECT Medical_Condition, YEAR(Admit_Date) AS Year,
		COUNT(*) AS Total_Admissions
	FROM hospitalrecords
    WHERE Admit_Date >= CURDATE() - INTERVAL 4 YEAR
    GROUP BY Medical_Condition, YEAR(Admit_Date)
)
SELECT Medical_Condition,
	SUM(CASE WHEN Year = YEAR(CURDATE()) - 4 THEN Total_Admissions ELSE 0 END) AS "2021_Admissions",
	SUM(CASE WHEN Year = YEAR(CURDATE()) - 3 THEN Total_Admissions ELSE 0 END) AS "2022_Admissions",
	SUM(CASE WHEN Year = YEAR(CURDATE()) - 2 THEN Total_Admissions ELSE 0 END) AS "2023_Admissions",
	SUM(CASE WHEN Year = YEAR(CURDATE()) - 1 THEN Total_Admissions ELSE 0 END) AS "2024_Admissions",
    ROUND(
    ((SUM(CASE WHEN Year = YEAR(CURDATE()) - 1 THEN Total_Admissions ELSE 0 END) -
	  SUM(CASE WHEN Year = YEAR(CURDATE()) - 2 THEN Total_Admissions ELSE 0 END)) * 100.0)/
      NULLIF(COALESCE(SUM(CASE WHEN Year = YEAR(CURDATE()) - 2 THEN Total_Admissions ELSE 0 END), 1), 0), 2
	) AS "Percentage_Increase"
FROM Medical_Condition_Trends
GROUP BY Medical_Condition
ORDER BY Percentage_Increase DESC;

/* Projected 2024 patient admissions */
WITH Medical_Condition_Trends AS (
    SELECT Medical_Condition, YEAR(Admit_Date) AS Year,
           COUNT(*) AS Total_Admissions
    FROM hospitalrecords
    WHERE Admit_Date >= CURDATE() - INTERVAL 4 YEAR
    GROUP BY Medical_Condition, YEAR(Admit_Date)
)
SELECT Medical_Condition,
    SUM(CASE WHEN Year = YEAR(CURDATE()) - 4 THEN Total_Admissions ELSE 0 END) AS "2021_Admissions",
    SUM(CASE WHEN Year = YEAR(CURDATE()) - 3 THEN Total_Admissions ELSE 0 END) AS "2022_Admissions",
    SUM(CASE WHEN Year = YEAR(CURDATE()) - 2 THEN Total_Admissions ELSE 0 END) AS "2023_Admissions",
    SUM(CASE WHEN Year = YEAR(CURDATE()) - 1 THEN Total_Admissions ELSE 0 END) AS "2024_Admissions_January-July",
    
    ROUND(SUM(CASE WHEN Year = YEAR(CURDATE()) - 1 THEN Total_Admissions ELSE 0 END) * (12.0 / 7), 0) 
    AS "Projected_2024_Admissions",

    ROUND(
        ((ROUND(SUM(CASE WHEN Year = YEAR(CURDATE()) - 1 THEN Total_Admissions ELSE 0 END) * (12.0 / 7), 0) -
          SUM(CASE WHEN Year = YEAR(CURDATE()) - 2 THEN Total_Admissions ELSE 0 END)) * 100.0) /
        NULLIF(COALESCE(SUM(CASE WHEN Year = YEAR(CURDATE()) - 2 THEN Total_Admissions ELSE 0 END), 1), 0), 2
    ) AS "Percentage_Increase"
FROM Medical_Condition_Trends
GROUP BY Medical_Condition
ORDER BY Percentage_Increase DESC;



    