#standardSQL
# Prevalence of /.well-known/change-password endpoints and counts for redirection and 'ok' HTTP status codes (https://fetch.spec.whatwg.org/#ok-status).
SELECT
  client,
  COUNT(DISTINCT page) AS total_pages,
  COUNTIF(has_change_password = 'true') AS count_has_change_password,
  COUNTIF(has_change_password = 'true') / COUNT(DISTINCT page) AS pct_has_change_password,
  COUNTIF(redirected = 'true') AS count_redirected,
  COUNTIF(redirected = 'true') / COUNTIF(has_change_password = 'true') AS pct_redirected,
  # `status` reflects the status code after redirection, so checking only for 200 is fine.
  COUNTIF(status = 200) AS count_status_200,
  COUNTIF(status = 200) / COUNTIF(has_change_password = 'true') AS pct_status_200,
  COUNTIF(status BETWEEN 201 AND 299) AS count_status_other_ok,
  COUNTIF(status BETWEEN 201 AND 299) / COUNTIF(has_change_password = 'true') AS pct_status_other_ok
FROM (
    SELECT
      _TABLE_SUFFIX AS client,
      url AS page,
      JSON_VALUE(JSON_VALUE(payload, '$._well-known'), '$."/.well-known/change-password".found') AS has_change_password,
      JSON_QUERY(JSON_VALUE(payload, '$._well-known'), '$."/.well-known/change-password".redirected') AS redirected,
      CAST(JSON_QUERY(JSON_VALUE(payload, '$._well-known'), '$."/.well-known/change-password".status') AS INT64) AS status
    FROM
      `httparchive.pages.2022_06_01_*`
)
GROUP BY
  client