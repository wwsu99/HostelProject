create database hostel;

use hostel; 

create table japan (
hostelid int,
name varchar(50),
city varchar(24),
distance varchar(24),
yenprice int,
score decimal(5,1),
rating varchar(12),
atmosphere decimal(4,1),
cleanliness decimal(4,1),
facilities decimal(4,1),
location decimal(4,1),
staff decimal(4,1),
value decimal(4,1),
security decimal(4,1),
lon decimal(7,4),
lat decimal(7,4)
);

-- Data Cleaning

Select *, Case
When lon > 145 THEN "Not in Japan"
When lon < 125 THEN "Not in Japan"
When lat > 45 THEN "Not in Japan"
When lat < 25 THEN "Not in Japan"
End as test
from japan
Order by test desc

-- Based on lon & lat coordinates, hostelid 17 was actually located in Singapore, so the record was dropped.  The max possible longitude to be in Japan is ~ 145 degrees east, and the latitude ~ 45 degrees north.  
-- The minimum possible lon & lat is ~125 degrees east and ~25 degrees north, respectively.  I created a case function to test these different values to make sure no other hostels were in other places where a value is null if it is in Japan, then sorted the results so that text values would come up first.

delete from japan 
where hostelid = 17
LIMIT 1;

-- Ordering by cost of stay per night in yen for any outliers.  Two records were showing as around 1,000,000 yen per night, or $8074.20 per night.  Just went back to the website and manually corrected these records.

Select *
from japan
order by yenprice;

Select *
from japan
order by yenprice DESC;

Update japan
SET yenprice = 3200
where hostelid = 290 OR hostelid=317
LIMIT 2;

Select *
From Japan
Where hostelid=290 OR hostelid=317;

-- Removing alphabetical text from the distance column so that they were numeric, and not mixed with string characters to create aggregate functions out of them later on.  Testing it in a select function before updating the table.  

Select *
From Japan
Order by distance;

Select *
From Japan
Order by distance desc;

Select replace(distance, "km from city centre", "")
From Japan;

Update Japan
Set distance = Replace(distance, "km from city centre", "")
;

-- Created a dollar price column based on March 26, 2022 yen to dollar conversion rates.  

Alter table Japan
Add dollarprice int
;

Update Japan
Set dollarprice = yenprice*.0082;

-- Updating the rating column to a rating scale that is more widely known and clear.  It also reduces the amount of space this column takes too by reducing the varchar of the column from 10 to 4.  
-- Originally I was just going to update the rating scale for hostels with scores less than 6, because they were input as "Rating" instead of having an actual rating band assigned to them, but I decided to alter the column altogether to take less space, and make more sense.   

select * 
From japan
Where score < 6.0
Order by score ASC
;

Alter table Japan
Add test varchar(20)
;

Update Japan
Set test = rating
;

Update Japan
Set test = Case
When 9.0 <= score AND score <= 10.0 THEN "A"
When 8.0 <= Score AND score < 9.0 THEN "B"
When 7.0 <= score AND score < 8.0 THEN "C"
When 6.0 <= score AND score < 7.0 THEN "D"
When 5.0 <= score AND score < 6.0 THEN "E"
When score < 5.0 THEN "F"
Else "ERROR"
END;

select *
From Japan
Where test = "Error";

select count(test), test
From Japan
Group by test
;

-- It was around here I realized that it wouldn't make sense to have two rating columns in addition to a score column, so I dropped the original rating column and changed the test column to the rating column.

Alter table Japan
drop column rating;

Alter table japan
rename column test to rating;

Alter table japan
modify rating varchar(4);

Select *
From Japan;

-- Aggregating these columns to pull up better information about the average hostel information in each of these cities.  I wanted to test a hypothesis if city location determined overall score and price. 
-- I saw that there might have been a relationship between the price of the hostel and the overall score, so I explored this further using a correlation analysis in Excel.  

Select distinct(City), Count(City), avg(dollarprice), avg(score)
From Japan
Group by city;

-- This is where I tested to see if I had any duplicate rows in the database before exporting the database to a CRV file.  If they had the same name, city, longitude, and latitude, then I would treat them as the same since they're in the same location with the same name, therefore, this is a duplicate row.  If it was a duplicate value, then they would have these values be the same, and then they would be assigned a row number that wasn't "1", with a row number of "1" being the first of this type of record.  If they had a row number of "2", for example, it would be treated as the second type of record of this data, and therefore should be deleted to make the analysis in Excel better.  

Select *, Row_number() over (
Partition by Name, City, lon, lat
Order BY hostelid
) row_num
From Japan
Order by row_num desc