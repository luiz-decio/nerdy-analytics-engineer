WITH first_orders AS (
    SELECT 
        client_id,
        MIN(order_creation_datetime) AS first_order_date
    FROM 
        ORDERS
    GROUP BY 
        client_id
),
valid_leads AS (
    SELECT 
        DATE(lead_creation_datetime) AS date,
        lead_source,
        COUNT(*) AS valid_leads
    FROM 
        LEADS
    WHERE 
        valid_lead = 1
    GROUP BY 
        DATE(lead_creation_datetime), lead_source
),
new_clients AS (
    SELECT 
        DATE(O.order_creation_datetime) AS date,
        L.lead_source,
        COUNT(DISTINCT C.client_id) AS new_clients
    FROM 
        CLIENTS C
    JOIN 
        LEADS L ON C.lead_id = L.lead_id
    JOIN 
        first_orders FO ON C.client_id = FO.client_id
    JOIN 
        ORDERS O ON C.client_id = O.client_id
    WHERE 
        FO.first_order_date = O.order_creation_datetime
    GROUP BY 
        DATE(O.order_creation_datetime), L.lead_source
),
orders AS (
    SELECT 
        DATE(O.order_creation_datetime) AS date,
        L.lead_source,
        COUNT(*) AS orders,
        SUM(O.order_amount) AS order_dollars
    FROM 
        ORDERS O
    JOIN 
        CLIENTS C ON O.client_id = C.client_id
    JOIN 
        LEADS L ON C.lead_id = L.lead_id
    GROUP BY 
        DATE(O.order_creation_datetime), L.lead_source
)
SELECT
    to_char(COALESCE(VL.date, NC.date, O.date), 'mm/dd/yyyy') AS "Date",
    COALESCE(VL.lead_source, NC.lead_source, O.lead_source) AS "Lead Source",
    COALESCE(VL.valid_leads, 0) AS "Valid Leads",
    COALESCE(NC.new_clients, 0) AS "New Clients",
    COALESCE(O.orders, 0) AS "Orders",
    CAST(COALESCE(O.order_dollars, 0)::numeric AS money) AS "Order Dollars"
FROM
    valid_leads AS VL
FULL OUTER JOIN
    new_clients AS NC ON VL.date = NC.date AND VL.lead_source = NC.lead_source
FULL OUTER JOIN
    orders AS O ON COALESCE(VL.date, NC.date) = O.date AND COALESCE(VL.lead_source, NC.lead_source) = O.lead_source
ORDER BY
    "Date" DESC, "Lead Source";