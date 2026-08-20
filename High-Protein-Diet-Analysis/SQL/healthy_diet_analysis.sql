/* =========================================================
   HEALTHY DIET & CALORIE INTAKE ANALYSIS
   Database: PostgreSQL
   Author: Michael Khaoya
   ========================================================= */


/* =========================================================
   1. DATA QUALITY & VALIDATION
   ========================================================= */

--Inspecting the table
select * 
from healthy_diet_calorie_intake hdci 
limit 5;

--Checking number of records
select count(*) as total_records
from healthy_diet_calorie_intake hdci;

--Checking duplicate IDs
select hdci."Person_ID" ,
		count(*) as records
from healthy_diet_calorie_intake hdci 
group by hdci."Person_ID"
having count(*) > 1;

--Checking for impossible values
-- I identified records with invalid negative carbohydrate intake
select * from healthy_diet_calorie_intake hdci where hdci."Carbohydrate_Intake_g" < 0;
select * from healthy_diet_calorie_intake hdci where hdci."Age" <= 0;
select * from healthy_diet_calorie_intake hdci where hdci."BMI"  <= 0;
select * from healthy_diet_calorie_intake hdci where hdci."Weight_kg"  <= 0;
select * from healthy_diet_calorie_intake hdci where hdci."Height_cm"  <= 0;
select * from healthy_diet_calorie_intake hdci where hdci."Water_Intake_Liters" <= 0;

-- Checking calorie Logic
select hdci."Person_ID",
		hdci."Daily_Calorie_Consumed",
		hdci."Daily_Calorie_Requirement", 
		(hdci."Daily_Calorie_Consumed"-hdci."Daily_Calorie_Requirement") as calorie_difference 
from healthy_diet_calorie_intake hdci 
limit 10;

/* =========================================================
   2.PARTICIPANT PROFILE
   ========================================================= */

-- How are participants distributed across activity levels?
select hdci."Activity_Level",
		count(hdci."Person_ID" ) as participants
from healthy_diet_calorie_intake hdci
group by hdci."Activity_Level" 
order by participants  DESC;

--What is the gender distribution of participants?
select HDCI."Gender" ,
count(hdci."Gender") as TOTAL 
from healthy_diet_calorie_intake hdci 
group by hdci."Gender"
order by TOTAL desc;

-- What is the age range of participants?
select max(hdci."Age" ) as oldest,
		min(hdci."Age" ) as youngest 
from healthy_diet_calorie_intake hdci;

--What is the avergae height for male and female?
select hdci."Gender",
		ROUND(AVG(hdci."Height_cm")::numeric,2)/30.48 as avg_height_ft 
from healthy_diet_calorie_intake hdci 
group by hdci."Gender" 
order by avg_height_ft  desc;

/* =========================================================
   3. NUTRITION
   ========================================================= */

-- What is the average protein,carbs, and fat intake?

select ROUND(AVG(hdci."Protein_Intake_g")::numeric,2) as avg_protein,
		ROUND(AVG(hdci."Carbohydrate_Intake_g")::numeric,2) as avg_carbs ,
		ROUND(AVG(hdci."Fat_Intake_g")::numeric,2) as avg_fat 
from healthy_diet_calorie_intake hdci;

--What is the average protein intake per activity level?
select hdci."Activity_Level",
		ROUND(AVG(hdci."Protein_Intake_g")::numeric,2) as avg_protein
from healthy_diet_calorie_intake hdci 
group by hdci."Activity_Level" ;

-- Which gender has the highest average fat intake?
select hdci."Gender" ,
		ROUND(AVG(hdci."Fat_Intake_g" )::NUMERIC,2) as Avg_Fat
from healthy_diet_calorie_intake hdci
group by hdci."Gender"  
order by avg_fat  desc; 

-- Which gender has the highest average protein intake?
select hdci."Gender",
ROUND(AVG(hdci."Protein_Intake_g")::numeric,2) as Avg_Protein 
from healthy_diet_calorie_intake hdci
group by hdci."Gender" 
order by avg_protein  DESC ;


/* =========================================================
   4. CALORIE BALANCE
   ========================================================= */

--How many people exceeded their daily calorie requirement?
select count(hdci."Person_ID" ) as excess_calories 
from healthy_diet_calorie_intake hdci 
where hdci."Daily_Calorie_Consumed" > hdci."Daily_Calorie_Requirement" ; 

--Which of the participants are meeting their calorie goals?
select case when hdci."Daily_Calorie_Consumed" > hdci."Daily_Calorie_Requirement" then 'Surplus'
			when hdci."Daily_Calorie_Consumed" = hdci."Daily_Calorie_Requirement" then 'At Requirement'
			else 'Deficit' end as calorie_status,
			count(*) as participants,
			ROUND(count(*) * 100.0/sum(count(*)) OVER(),2) as percentage
from healthy_diet_calorie_intake hdci 
group by case when hdci."Daily_Calorie_Consumed" > hdci."Daily_Calorie_Requirement" then 'Surplus'
			when hdci."Daily_Calorie_Consumed" = hdci."Daily_Calorie_Requirement" then 'At Requirement'
			else 'Deficit' end
order by participants DESC;

-- What is the relationship between average protein and average calories?
select 	
	hdci."Diet_Type" ,
	count(*) as participants,
	round(avg(hdci."Protein_Intake_g" )::numeric,2) as avg_protein_g,
	round(avg(hdci."Daily_Calorie_Consumed" )::numeric,2) as avg_calories
from healthy_diet_calorie_intake hdci 
group by "Diet_Type" 
order by avg_protein_g desc;
/* =========================================================
   5. BMI & HEALTH
   ========================================================= */

--How many people per health status?
select hdci."Health_Status" ,
		count(hdci."Person_ID" ) 
from healthy_diet_calorie_intake hdci
group by hdci."Health_Status" 
order by count desc;

-- How does average BMI vary across diet types?
select hdci."Diet_Type" ,
		ROUND(AVG(hdci."BMI" )::NUMERIC,2) as AVG_BMI 
from healthy_diet_calorie_intake hdci
group by hdci."Diet_Type" 
order by avg_bmi  DESC;

-- How does average BMI vary by health status?
select hdci."Health_Status",
		count(*) as participants,
		ROUND(AVG(hdci."BMI")::numeric,2) as avg_bmi
from healthy_diet_calorie_intake hdci 
group by hdci."Health_Status" 
order by avg_bmi desc;

-- How many participants have a high BMI?
with HighBMIIndividuals as (select hdci."Person_ID",hdci."BMI" from healthy_diet_calorie_intake hdci where hdci."BMI" > 25)
select count(HighBMIIndividuals."BMI" ) from HighBMIIndividuals; 

-- What is the avg_protein per health status?
select 
	hdci."Health_Status" ,
	count(*) as participants,
	round(avg(hdci."Protein_Intake_g" )::numeric,2) as avg_protein_g,
	round(avg(hdci."BMI" )::numeric,2) as avg_bmi
from healthy_diet_calorie_intake hdci 
group by hdci."Health_Status" 
order by avg_protein_g desc;

-- What is the average protein intake per health status and activity level?
select 
	hdci."Health_Status"  ,
	hdci."Activity_Level" ,
	count(*) as participants,
	round(avg(hdci."Protein_Intake_g" )::numeric,2) as avg_protein
from healthy_diet_calorie_intake hdci 
group by "Activity_Level" , "Health_Status"  
order by avg_protein desc;


/* =========================================================
   6. DIET
   ========================================================= */

--What is the most popular diet type?
select hdci."Diet_Type",
		count(*) as participants,
		ROUND(count(*) * 100.0 / sum(count(*)) over(),2) as percentage 
from healthy_diet_calorie_intake hdci 
group by hdci."Diet_Type" 
order by participants  desc;

--How does average protein intake vary across diet types?
select hdci."Diet_Type" ,
		count(*) as participants,
		round(avg(hdci."Protein_Intake_g" )::numeric,2) as avg_protein_diet_type
from healthy_diet_calorie_intake hdci 
group by hdci."Diet_Type" 
order by avg_protein_diet_type DESC;


/* =========================================================
   7. ADVANCED/ADDITIONAL ANALYSIS
   ========================================================= */

-- Who consumes the lowest amount of protein and what is their activity level and age?
select hdci."Person_ID" ,
		hdci."Age" ,
		hdci."Activity_Level" , 
		hdci."Protein_Intake_g" 
from healthy_diet_calorie_intake hdci
order by hdci."Protein_Intake_g" 
limit 1;

-- Which consumers consume the most amount of water?
select hdci."Person_ID" ,
	hdci."Water_Intake_Liters" ,
	RANK() OVER(order by hdci."Water_Intake_Liters" desc ) as Water_Rank
from healthy_diet_calorie_intake hdci
limit 10;


--Who are the 10 highest consumers of protein?
select hdci."Person_ID",
hdci."Protein_Intake_g",
RANK()  over(order by hdci."Protein_Intake_g"  DESC ) as protein_ranking
from healthy_diet_calorie_intake hdci limit 10;