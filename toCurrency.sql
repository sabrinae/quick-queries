CREATE TEMP FUNCTION toCurrency(obj FLOAT64)
  RETURNS STRING
  LANGUAGE js AS """
    return "$" + obj.toFixed(2);
  """;

WITH table_1 AS (
SELECT 
  Advertiser, 
  #campaign_name AS Campaign_Name,campaign_type AS Campaign_Type,MIN(start_date) AS Start_Date,MAX(end_date) AS End_Date, 
  SUM(total_GROSS_budget) AS TotalBudget, 
  SUM(total_GROSS_spend) AS TotalSpend, 
  SUM(impressions) AS Impressions, 
  SUM(clicks) AS Clicks,
  SUM(weighted_actions) AS WeightedActions
FROM
  `tableau-data-249113.simplifi_monthly_data.sf_monthly_DoD_201912*`
WHERE
  Advertiser = 'some client name' AND total_GROSS_spend > 1
GROUP BY
  Advertiser #, campaign_name, campaign_type
)
SELECT 
  Advertiser,
  #Campaign_Name, Campaign_Type,
  toCurrency(TotalBudget) AS Total_Budget,
  toCurrency(TotalSpend) AS Total_Spend,
  Impressions,
  Clicks,
  WeightedActions,
  ROUND(Clicks / Impressions, 4) AS CTR,
  ROUND(SAFE_DIVIDE(TotalSpend,Impressions) * 1000, 3) AS CPM,
  ROUND(SAFE_DIVIDE(TotalSpend,Clicks), 3) AS CPC,
  ROUND(SAFE_DIVIDE(TotalSpend,WeightedActions), 3) AS CPA
FROM 
  table_1
