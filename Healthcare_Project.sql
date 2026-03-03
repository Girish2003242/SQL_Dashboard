USE classicmodels;

-- KPI 1: Total Patients, Doctors, Visits, Revenue
SELECT
    (SELECT COUNT(*) FROM Patient) AS Total_Patients,
    (SELECT COUNT(*) FROM Doctor) AS Total_Doctors,
    (SELECT COUNT(*) FROM Visit) AS Total_Visits;
SELECT CONCAT(ROUND(SUM(Cost)/ 100000, 2), 'M') AS Total_Revenue FROM Treatment;

-- KPI 2: Monthly Visit Trend (Using DATE Functions)
SELECT 
    DATE_FORMAT(Visit_Date, '%Y-%m') AS Month,
    COUNT(*) AS Total_Visits
FROM Visit
GROUP BY DATE_FORMAT(Visit_Date, '%Y-%m')
ORDER BY Month;




-- KPI 3: Top 5 Diagnosed Diseases (Window Function)
WITH Diagnosis_Count AS (
    SELECT 
        Diagnosis,
        COUNT(*) AS Total_Cases
    FROM Visit
    GROUP BY Diagnosis
)

SELECT *
FROM (
    SELECT *,
           RANK() OVER (ORDER BY Total_Cases DESC) AS Rank_No
    FROM Diagnosis_Count
) ranked
WHERE Rank_No <= 5;

-- KPI 4: Appointment Cancellation Rate (Percentage)
SELECT 
    CONCAT(ROUND(
        SUM(CASE WHEN visit_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2), '%'
    ) AS cancellation_rate_percentage
FROM visit;

-- KPI 5: Treatment Success Rate
SELECT 
    Treatment_Type,
    COUNT(*) AS Total_Treatments,
    SUM(CASE WHEN Outcome = 'Successful' THEN 1 ELSE 0 END) AS Successful_Treatments,
    CONCAT(ROUND(
        SUM(CASE WHEN Outcome = 'Successful' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2
    ), '%') AS Success_Rate_Percentage
FROM Treatment
GROUP BY Treatment_Type;

-- KPI 6: Abnormal Lab Results Percentage
SELECT 
    COUNT(*) AS Total_Tests,
    SUM(CASE WHEN Test_Result = 'Abnormal' THEN 1 ELSE 0 END) AS Abnormal_Tests,
    CONCAT(ROUND(
        SUM(CASE WHEN Test_Result = 'Abnormal' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2
    ), '%') AS Abnormal_Percentage
FROM Lab_test;

-- KPI 7: State-wise Patient Distribution
SELECT 
    State,
    COUNT(*) AS Total_Patients
FROM Patient
GROUP BY State
ORDER BY Total_Patients DESC;

-- KPI 8: Follow-up Required Rate
SELECT 
    Follow_Up_Required,
    COUNT(*) AS Total_Visits
FROM Visit
GROUP BY Follow_Up_Required;

-- KPI 9: Patient Age Group Distribution
SELECT 
    CASE 
        WHEN Age < 18 THEN 'Children'
        WHEN Age BETWEEN 18 AND 40 THEN 'Young Adults'
        WHEN Age BETWEEN 41 AND 60 THEN 'Adults'
        ELSE 'Senior'
    END AS Age_Group,
    COUNT(*) AS Total_Patients
FROM Patient
GROUP BY Age_Group
ORDER BY Total_Patients DESC;


-- KPI 10: Most Experienced Doctors (Top 3 per Specialty)
SELECT *
FROM (
    SELECT 
        Specialty,
        Doctor_Name,
        Years_Of_Experience,
        ROW_NUMBER() OVER (
            PARTITION BY Specialty 
            ORDER BY Years_Of_Experience DESC
        ) AS Rank_No
    FROM Doctor
) ranked
WHERE Rank_No <= 5;


