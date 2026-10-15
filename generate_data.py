"""Generates the CSV files used by the pipeline. Run: python3 generate_data.py"""
import csv, random
from datetime import date, timedelta

random.seed(42)
CITIES = ["Bengaluru", "Mysuru", "Chennai", "Hyderabad", "Pune", "Mumbai", "Delhi"]

# Day 1: 5,000 customers
customers = {i: (f"Customer {i}", f"user{i}@example.com", random.choice(CITIES)) for i in range(1, 5001)}
with open("data/customers_day1.csv", "w", newline="") as f:
    w = csv.writer(f, lineterminator="\n"); w.writerow(["customer_id", "name", "email", "city"])
    for cid, row in customers.items():
        w.writerow([cid, *row])

# Day 2: 200 existing customers move city (UPDATE), 100 brand-new customers (INSERT),
# everyone else unchanged (MERGE should leave them alone)
day2 = dict(customers)
for cid in random.sample(range(1, 5001), 200):
    n, e, c = day2[cid]
    day2[cid] = (n, e, random.choice([x for x in CITIES if x != c]))
for cid in range(5001, 5101):
    day2[cid] = (f"Customer {cid}", f"user{cid}@example.com", random.choice(CITIES))
with open("data/customers_day2.csv", "w", newline="") as f:
    w = csv.writer(f, lineterminator="\n"); w.writerow(["customer_id", "name", "email", "city"])
    for cid, row in day2.items():
        w.writerow([cid, *row])

# Orders: 200,000 rows Jan-Jun 2026, ~5% PENDING (makes the partial index worthwhile)
start, days = date(2026, 1, 1), 181
with open("data/orders.csv", "w", newline="") as f:
    w = csv.writer(f, lineterminator="\n"); w.writerow(["order_id", "customer_id", "order_date", "amount", "status"])
    for oid in range(1, 200_001):
        d = start + timedelta(days=random.randrange(days))
        status = random.choices(["PENDING", "SHIPPED", "DELIVERED", "CANCELLED"], [5, 25, 65, 5])[0]
        w.writerow([oid, random.randint(1, 5000), d, round(random.uniform(5, 500), 2), status])
print("Done: data/customers_day1.csv, customers_day2.csv, orders.csv")
