# Acme Corp — Service Level Agreement (SLA)
**Document Version:** 2.3 | **Last Updated:** January 2026 | **Owner:** Operations Team

## 1. Uptime Guarantee

| Plan | Uptime SLA | Monthly Allowed Downtime |
|------|-----------|------------------------|
| Starter | 99.0% | 7 hours 18 minutes |
| Professional | 99.5% | 3 hours 39 minutes |
| Enterprise | 99.9% | 43 minutes |
| Enterprise Plus | 99.95% | 21 minutes |

## 2. SLA Credits
If Acme Corp fails to meet the uptime SLA, customers receive service credits:

| Uptime Achieved | Credit (% of monthly bill) |
|----------------|---------------------------|
| 99.0% - 99.9% | 10% credit |
| 95.0% - 99.0% | 25% credit |
| 90.0% - 95.0% | 50% credit |
| Below 90.0% | 100% credit |

Credits must be requested within 30 days of the incident.

## 3. Scheduled Maintenance
- Maintenance windows: **Sundays, 2:00 AM - 6:00 AM UTC**
- Customers notified **72 hours** in advance via email
- Scheduled maintenance does NOT count against SLA uptime

## 4. Incident Response Times

| Severity | Description | Enterprise Response | Enterprise+ Response |
|----------|-------------|-------------------|---------------------|
| **P1 - Critical** | Service completely unavailable | 1 hour | 15 minutes |
| **P2 - Major** | Major feature unavailable | 4 hours | 1 hour |
| **P3 - Minor** | Minor issue, workaround available | 8 hours | 4 hours |
| **P4 - Low** | Cosmetic or documentation issue | 24 hours | 8 hours |

## 5. Data Backup & Recovery
- All customer data backed up **every 6 hours**
- Backups retained for **30 days**
- Point-in-time recovery available for Enterprise+ customers
- Recovery Time Objective (RTO): 4 hours
- Recovery Point Objective (RPO): 6 hours
