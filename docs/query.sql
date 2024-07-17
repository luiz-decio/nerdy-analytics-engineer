-- CTE to find the first order date for each client
WITH first_orders AS (
    SELECT 
        client_id,
        MIN(order_creation_datetime) AS first_order_date
    FROM 
        ORDERS
    GROUP BY 
        client_id
),

-- CTE to count valid leads by date and lead source
valid_leads AS (
    SELECT 
        DATE(lead_creation_datetime) AS date,  -- Extract the date part from the timestamp
        lead_source,
        COUNT(*) AS valid_leads  -- Count of valid leads
    FROM 
        LEADS
    WHERE 
        valid_lead = 1  -- Filter for valid leads
    GROUP BY 
        DATE(lead_creation_datetime), lead_source
),

-- CTE to count new clients by the date of their first order and lead source
new_clients AS (
    SELECT 
        DATE(O.order_creation_datetime) AS date,  -- Date of the order
        L.lead_source,
        COUNT(DISTINCT C.client_id) AS new_clients  -- Count of unique new clients
    FROM 
        CLIENTS C
    JOIN 
        LEADS L ON C.lead_id = L.lead_id  -- Join to link clients to their lead sources
    JOIN 
        first_orders FO ON C.client_id = FO.client_id  -- Join to filter for first orders
    JOIN 
        ORDERS O ON C.client_id = O.client_id
    WHERE 
        FO.first_order_date = O.order_creation_datetime  -- Ensure it's the first order
    GROUP BY 
        DATE(O.order_creation_datetime), L.lead_source
),

-- CTE to count orders and sum order amounts by date and lead source
orders AS (
    SELECT 
        DATE(O.order_creation_datetime) AS date,  -- Date of the order
        L.lead_source,
        COUNT(*) AS orders,  -- Total number of orders
        SUM(O.order_amount) AS order_dollars  -- Total order amount in dollars
    FROM 
        ORDERS O
    JOIN 
        CLIENTS C ON O.client_id = C.client_id  -- Join to link orders to clients
    JOIN 
        LEADS L ON C.lead_id = L.lead_id  -- Join to link clients to their lead sources
    GROUP BY 
        DATE(O.order_creation_datetime), L.lead_source
)

-- Main query to combine results from the CTEs
SELECT
    to_char(COALESCE(VL.date, NC.date, O.date), 'mm/dd/yyyy') AS "Date",  -- Format date as mm/dd/yyyy
    COALESCE(VL.lead_source, NC.lead_source, O.lead_source) AS "Lead Source",  -- Determine lead source
    COALESCE(VL.valid_leads, 0) AS "Valid Leads",  -- Default to 0 if no valid leads
    COALESCE(NC.new_clients, 0) AS "New Clients",  -- Default to 0 if no new clients
    COALESCE(O.orders, 0) AS "Orders",  -- Default to 0 if no orders
    CAST(COALESCE(O.order_dollars, 0)::numeric AS money) AS "Order Dollars"  -- Default to 0 and cast to money type
FROM
    valid_leads AS VL
FULL OUTER JOIN
    new_clients AS NC ON VL.date = NC.date AND VL.lead_source = NC.lead_source
FULL OUTER JOIN
    orders AS O ON COALESCE(VL.date, NC.date) = O.date AND COALESCE(VL.lead_source, NC.lead_source) = O.lead_source
ORDER BY
    "Date" DESC, "Lead Source";  -- Order by date descending and then by lead source
