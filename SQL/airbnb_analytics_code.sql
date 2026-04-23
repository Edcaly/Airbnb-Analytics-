---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
 
--                                EDCALY LAGUERRE & LALA FALL

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


/*
QUESTION 1: 
Which Manhattan neighborhoods command the highest nightly rates, 
and what is the gap between the cheapest and most expensive listings?
*/

SELECT 
    L.neighbourhood AS Neighborhood,
    COUNT(LI.Listing_id) AS Total_Listings,
    ROUND(AVG(LI.price), 2) AS Avg_Nightly_Rate,
    MIN(LI.price) AS Min_Price,
    MAX(LI.price) AS Max_Price,
    (MAX(LI.price) - MIN(LI.price)) AS Price_Gap
FROM Property.Location L
JOIN Operations.Listings LI ON L.Location_ID = LI.Location_id
WHERE L.district = 'Manhattan'
GROUP BY L.neighbourhood
ORDER BY Avg_Nightly_Rate DESC;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

/* 
Question 2: 
where is Airbnb actually generating the most revenue across manhattan?
*/

SELECT 
    L.neighbourhood,
    (AVG(LI.price) * COUNT(B.Listing_id)) AS Totoal_Revenue
FROM
    Property.[Location] L
JOIN
    Operations.Listings LI ON L.Location_ID = LI.Location_id
JOIN
    Operations.Bookings B ON LI.Listing_id = B.Listing_id
GROUP BY 
    L.neighbourhood
ORDER BY 
    Totoal_Revenue DESC; 

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

/*
Question 3: 
Between entire apartments, private rooms, hotel rooms and shared rooms. 
Which listing type is our guest choosing the most, and which gets the best reviews?
*/

SELECT 
    P.room_type AS [Room Type],
    COUNT(B.BookingID) AS [Total Bookings],
    ROUND(AVG(R.review_scores_rating), 2) AS [Avg Guest Rating],
    ROUND(AVG(LI.price), 2) AS [Avg Price]
FROM Property.Properties P
JOIN Operations.Listings LI ON P.Property_ID = LI.Property_id
LEFT JOIN Operations.Bookings B ON LI.Listing_id = B.Listing_id
LEFT JOIN Operations.Reviews R ON LI.Listing_id = R.Listing_id
GROUP BY P.room_type
ORDER BY [Total Bookings] DESC;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

/*
Question 4: 
I keep hearing that our superhost programme drives better outcomes. 
Do superhosts actually earn more and get higher ratings than regular hosts?
*/ 

SELECT 
CASE
    WHEN H.IsSuperHost = 't' THEN 'Super HOst'
    ELSE 'Regular Host'
    END AS Host_Type,
COUNT(DISTINCT(H.HostID)) AS 'Total_Hosts',
ROUND(AVG(LI.price), 2) AS 'AVG_Price',
COUNT(B.Listing_id) AS 'Total_Bookings',
ROUND(AVG(R.review_scores_rating), 2) AS 'Review_Rating'
FROM Users.Hosts H
JOIN Property.Properties P ON H.HostID = P.Host_ID
JOIN Operations.Listings LI ON P.Property_ID = LI.Property_id
LEFT JOIN Operations.Bookings B ON LI.Listing_id = B.Listing_id
LEFT JOIN Operations.Reviews R ON LI.Listing_id = R.Listing_id
GROUP BY H.IsSuperhost;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

/*
Question 5: 
Where are our manhattan hosts actually based? 
We want to understand whether local host or remote host are running the majority of our listings
*/ 

WITH HostCategory AS (
    SELECT 
        LI.Listing_id,
        CASE 
            WHEN H.HostLocation LIKE '%New York%' 
                 OR H.HostLocation LIKE '%NY%' 
                 OR H.HostLocation LIKE '%Manhattan%' THEN 'Local (NYC)'
            ELSE 'Remote (Out of Town)'
        END AS Host_Proximity
    FROM Users.Hosts H
    JOIN Property.Properties P ON H.HostID = P.Host_ID
    JOIN Property.Location L ON P.Location_ID = L.Location_ID
    JOIN Operations.Listings LI ON P.Property_ID = LI.Property_id
    WHERE L.district = 'Manhattan'
)
SELECT 
    Host_Proximity,
    COUNT(Listing_id) AS Total_Listings,
    CAST(COUNT(Listing_id) * 100.0 / SUM(COUNT(Listing_id)) OVER() AS DECIMAL(10,2)) AS [Percentage_of_Market]
FROM HostCategory
GROUP BY Host_Proximity;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

/* 
Question 6: 
When during  the year are our guests booking the most? 
Are there seasonal peaks we should be preparing our hosts and pricing algorithms for?
*/ 

SELECT 
    MONTH(B.CheckInDate) AS [Month_Number],
    DATENAME(MONTH, B.CheckInDate) AS [Month_Name],
    COUNT(B.BookingID) AS [Total_Bookings],
    ROUND(SUM(B.TotalPaid), 2) AS [Total_Monthly_Revenue],
    ROUND(AVG(LI.price), 2) AS [Avg_Nightly_Price]
FROM Operations.Bookings B
JOIN Operations.Listings LI ON B.Listing_id = LI.Listing_id
GROUP BY MONTH(B.CheckInDate), DATENAME(MONTH, B.CheckInDate)
ORDER BY [Month_Number] ASC;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

/* 
Question 7: 
Give me a single snapshot of the manhattan market right now, total active listings, 
average nightly price, total revenue generated, and average guest rating 
*/

DECLARE @TargetDistrict NVARCHAR(50);

SET @TargetDistrict = 'Manhattan';

SELECT 
    @TargetDistrict AS Market,
    COUNT(DISTINCT LI.Listing_id) AS Total_Active_Listings,
    ROUND(AVG(LI.price), 2) AS Avg_Nightly_Price,
    ROUND(SUM(B.TotalPaid), 0) AS Total_Revenue_Generated,
    ROUND(AVG(R.review_scores_rating), 2) AS Avg_Guest_Rating
FROM Property.Location L
JOIN Operations.Listings LI ON L.Location_ID = LI.Location_id
LEFT JOIN Operations.Bookings B ON LI.Listing_id = B.Listing_id
LEFT JOIN Operations.Reviews R ON LI.Listing_id = R.Listing_id
WHERE L.district = @TargetDistrict;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

/*
Question 8: 
Which hosts are changing significantly above what their neighborhood’s market rate would justify? 
We want to flag potential guests trust issues before they hurt our ratings.
*/

SELECT 
    L.neighbourhood,
    COUNT(CASE WHEN P.room_type = 'Entire home/apt' THEN 1 END) AS Entire_Home_Count,
    COUNT(CASE WHEN P.room_type = 'Private room' THEN 1 END) AS Private_Room_Count,
    COUNT(CASE WHEN P.room_type = 'Shared room' THEN 1 END) AS Shared_Room_Count
FROM Property.Location L
JOIN Operations.Listings LI ON L.Location_ID = LI.Location_id
JOIN Property.Properties P ON LI.Property_id = P.Property_ID
GROUP BY L.neighbourhood;


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


/*
Question 9: 
How many of our listings have never received a single review? That is a major conversation problem, 
We need to know the scale of it and which neighborhoods it’s concentrated in.
*/

SELECT 
    L.neighbourhood,
    COUNT(LI.Listing_id) AS Unreviewed_Count,
    ROUND(AVG(LI.price), 2) AS Avg_Price_of_Unreviewed
FROM Property.Location L
JOIN Operations.Listings LI ON L.Location_id = LI.Location_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM Operations.Reviews R 
    WHERE R.Listing_id = LI.Listing_id
)
GROUP BY L.neighbourhood
ORDER BY Unreviewed_Count DESC;

/*
Question 10: 
How long have our reviewed hosts been on the platform? 
We want to understand whether more experienced hosts are the ones actually getting guest feedback
*/

SELECT 
    H.HostID,
    DATEDIFF(YEAR, H.HostSince, GETDATE()) AS Years_On_Platform,
    COUNT(R.Review_ID) AS Total_Reviews_Received
FROM Users.Hosts H
JOIN Property.Properties P ON H.HostID = P.Host_ID 
JOIN Operations.Listings LI ON P.Property_ID = LI.Property_id
LEFT JOIN Operations.Reviews R ON LI.Listing_id = R.Listing_id
WHERE EXISTS (
    SELECT 1 FROM Operations.Reviews Sub_R 
    WHERE Sub_R.Listing_id = LI.Listing_id
)
GROUP BY H.HostID, H.HostSince
HAVING COUNT(R.Review_ID) > 50 
ORDER BY Years_On_Platform DESC;


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


/*
Question 11: 
Within each neighborhood, which individual listings are generating the most revenue? 
We want a ranked leaderboard by area so we can identify our star performers
*/

GO
CREATE VIEW vw_Neighborhood_Leaderboard AS
WITH Revenue_Calculation AS (
    SELECT 
        L.neighbourhood,
        LI.Listing_id,
        SUM(B.TotalPaid) AS Total_Revenue
    FROM Property.Location L
    JOIN Operations.Listings LI ON L.Location_ID = LI.Location_id
    JOIN Operations.Bookings B ON LI.Listing_id = B.Listing_id
    GROUP BY L.neighbourhood, LI.Listing_id
),
Max_Revenue_Per_Neighborhood AS (
    SELECT 
        neighbourhood,
        MAX(Total_Revenue) AS Max_Revenue
    FROM Revenue_Calculation
    GROUP BY neighbourhood
)
SELECT 
    rc.neighbourhood,
    rc.Listing_id,
    rc.Total_Revenue
FROM Revenue_Calculation rc
JOIN Max_Revenue_Per_Neighborhood mr 
    ON rc.neighbourhood = mr.neighbourhood 
    AND rc.Total_Revenue = mr.Max_Revenue;
GO

SELECT * FROM vw_Neighborhood_Leaderboard;


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


/*
Question 12: 
Are business travelers, family groups or solo travelers spending more per booking and staying longer? 
We want to know which guest segment we should be prioritizing in our marketing
*/

GO
CREATE PROCEDURE sp_AnalyzeGuestSegment
    @TripType NVARCHAR(50) 
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Users.Tenants WHERE TripPurpose = @TripType)
    BEGIN
        WITH Raw_Segment_Data AS (
            SELECT 
                T.TripPurpose,
                B.TotalPaid,
                B.StayDuration
            FROM Users.Tenants T
            JOIN Operations.Bookings B ON T.TenantID = B.TenantID
            WHERE T.TripPurpose = @TripType
        ),
        Final_Metrics AS (
            SELECT 
                TripPurpose,
                COUNT(*) AS Total_Bookings,
                ROUND(AVG(StayDuration), 2) AS Avg_Stay_Length,
                ROUND(AVG(TotalPaid), 2) AS Avg_Booking_Value,
                SUM(TotalPaid) AS Total_Revenue
            FROM Raw_Segment_Data
            GROUP BY TripPurpose
        )
        SELECT * FROM Final_Metrics;
    END
    ELSE
    BEGIN
        PRINT 'The specified Trip Purpose was not found in the database.';
    END
END;
GO


-- EXEC sp_AnalyzeGuestSegment @TripType = 'Business';


---------------------------------------------------------------------------------------------------------
-- Alright Reserved - Edcaly Laguerre & Lala Fall 
---------------------------------------------------------------------------------------------------------
