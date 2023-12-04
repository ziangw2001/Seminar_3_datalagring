/* Table 1*/ 

SELECT
    "Month",
    SUM(
		CASE 
			WHEN "type" = 'Individual_lesson' THEN 1 
			ELSE 0 END) AS "Individual",
    SUM(
		CASE 
			WHEN "type" = 'Group_lesson' THEN 1 
			ELSE 0 END) AS "Group",
    SUM(
		CASE 
			WHEN "type" = 'Ensemble_lesson' THEN 1 
			ELSE 0 END) AS "Ensemble",
    --- These lines use CASE statements within SUM functions to 
	--- count the occurrences of each lesson type based on the 
	--- "type" column created earlier. 
	--- For each row, it adds 1 to the respective count column 
	--- if the condition in the CASE statement is met; otherwise, it adds 0.
	
	SUM(1) AS "Total"

FROM (
    SELECT
        TO_CHAR(TO_DATE(date, 'YYYY-MM-DD'), 'Mon') AS "Month",
	--- Converts the date column into abbreviated month names (like 'Jan', 'Feb', etc.) 
	--- to group the lessons by month.
        'Individual_lesson' AS "type"
    FROM
        individual_lesson
	
    UNION ALL
	
    SELECT
        TO_CHAR(TO_DATE(date, 'YYYY-MM-DD'), 'Mon') AS "Month",
        'Group_lesson' AS "type"
    FROM
        group_lesson
	
    UNION ALL
    
	SELECT
        TO_CHAR(TO_DATE(date, 'YYYY-MM-DD'), 'Mon') AS "Month",
        'Ensemble_lesson' AS "type"
    FROM
        ensemble
	
) AS CombinedLessons

WHERE
    "Month" IN ('Oct', 'Nov', 'Dec')
GROUP BY
    "Month"

ORDER BY CASE 
            WHEN "Month" = 'Oct' THEN 1
            WHEN "Month" = 'Nov' THEN 2
            WHEN "Month" = 'Dec' THEN 3  
			
END;



/* Table 2 */
SELECT Number_of_siblings, COUNT(*) AS Number
FROM (
    SELECT person_id,
           CASE
               WHEN COUNT(*) = 1 THEN 1
				ELSE 2

           END AS Number_of_siblings
	--- Here, it counts the occurrences of each person_id in 
	--- the sibling_relation table to determine the number of siblings (Number_of_siblings). 
	--- If a person appears once, they are considered to have 1 sibling; otherwise, 
	--- they are considered to have 2 or more siblings (2 in my opinion).
	
    FROM (
        SELECT person1_id AS person_id FROM sibling_relation
        UNION ALL
        SELECT person2_id AS person_id FROM sibling_relation
		
    ) AS person_with_siblings
    LEFT JOIN sibling_relation ON person_with_siblings.person_id = sibling_relation.person1_id OR person_with_siblings.person_id = sibling_relation.person2_id
    GROUP BY person_id
   
	
    UNION ALL
    
    SELECT 0 AS person_id, 0 AS Number_of_siblings -- Students without siblings
    FROM student
    WHERE person_ID NOT IN (
        SELECT DISTINCT person1_id FROM sibling_relation
        UNION
        SELECT DISTINCT person2_id FROM sibling_relation
    )
) AS person_without_sibings
GROUP BY Number_of_siblings
ORDER BY Number_of_siblings;


/* Table 3 */
SELECT 
    instructor.instructor_ID,
    person.first_name,
    person.last_name,
    COUNT(*) AS lesson_count
FROM 
    (
        SELECT instructor_ID, date FROM individual_lesson
        UNION ALL
        SELECT instructor_ID, date FROM group_lesson
    ) AS lesson
JOIN 
    instructor ON lesson.instructor_ID = instructor.instructor_ID
JOIN 
    person ON instructor.person_id = person.person_id
WHERE 
    EXTRACT(MONTH FROM CAST(lesson.date AS DATE)) = 10 
	AND EXTRACT(YEAR FROM CAST(lesson.date AS DATE)) = 2023
	
GROUP BY 
    instructor.instructor_ID, person.first_name, person.last_name
HAVING 
    COUNT(*) > 3;



/* Table 4 */
SELECT
    TO_CHAR(date::DATE, 'Dy') AS Day,
    music_genre AS Genre,
    CASE
        WHEN max_student < attendee THEN 'ERROR'
        WHEN max_student - attendee <= 0 THEN 'No Seats'
        WHEN max_student - attendee <= 2 THEN '1 or 2 Seats'
        ELSE 'Many Seats'
    END AS "No of Free Seats"
FROM
    ensemble
WHERE
    date::DATE BETWEEN '2023-10-01' AND '2023-10-08'::DATE

ORDER BY
    
	CASE 
        WHEN TO_CHAR(date::DATE, 'Dy') = 'Mon' THEN 1
        WHEN TO_CHAR(date::DATE, 'Dy') = 'Tue' THEN 2
        WHEN TO_CHAR(date::DATE, 'Dy') = 'Wed' THEN 3
        WHEN TO_CHAR(date::DATE, 'Dy') = 'Thu' THEN 4
        WHEN TO_CHAR(date::DATE, 'Dy') = 'Fri' THEN 5
        WHEN TO_CHAR(date::DATE, 'Dy') = 'Sat' THEN 6
        WHEN TO_CHAR(date::DATE, 'Dy') = 'Sun' THEN 7
    END;





/* 
ADD FK:

ALTER TABLE individual_lesson
ADD CONSTRAINT fk_instructor_id
FOREIGN KEY (instructor_id)
REFERENCES instructor(instructor_id);

*/
