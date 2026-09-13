SHOW DATABASES;

# Q1 Busiest Route 

SELECT r.route_code, r.route_name, SUM(rd.passengers) AS total_pax,
       RANK() OVER (ORDER BY SUM(rd.passengers) DESC) AS pax_rank
FROM routes r
JOIN trips t ON t.route_id = r.route_id
JOIN ridership rd ON rd.trip_id = t.trip_id
GROUP BY r.route_id, r.route_code, r.route_name
ORDER BY total_pax DESC;

# Q2 Occupancy 

SELECT t.trip_id, r.route_code, t.departure_time,
       b.capacity, SUM(rd.passengers) AS pax,
       ROUND(100.0 * SUM(rd.passengers) / b.capacity, 1) AS occupancy_pct,
       AVG(SUM(rd.passengers)) OVER (PARTITION BY r.route_id) AS route_avg_pax
FROM trips t
JOIN routes r ON r.route_id = t.route_id
JOIN buses b ON b.bus_id = t.bus_id
JOIN ridership rd ON rd.trip_id = t.trip_id
GROUP BY t.trip_id, r.route_code, t.departure_time, b.capacity
ORDER BY occupancy_pct DESC
LIMIT 15;

# Q3. Peak-hour demand per route
SELECT route_code, hr, pax,
       SUM(pax) OVER (PARTITION BY route_code ORDER BY hr) AS running_total
FROM (
    SELECT r.route_code, HOUR(t.departure_time) AS hr,
           SUM(rd.passengers) AS pax
    FROM trips t
    JOIN routes r ON r.route_id = t.route_id
    JOIN ridership rd ON rd.trip_id = t.trip_id
    GROUP BY r.route_code, HOUR(t.departure_time)
) hourly
ORDER BY route_code, hr;

# Q4. Most crowded stop-pair
SELECT r.route_code, s1.stop_name AS from_stop, s2.stop_name AS to_stop,
       SUM(rd.passengers) AS pax
FROM ridership rd
JOIN trips t ON t.trip_id = rd.trip_id
JOIN routes r ON r.route_id = t.route_id
JOIN stops s1 ON s1.stop_id = rd.boarding_stop_id
JOIN stops s2 ON s2.stop_id = rd.alighting_stop_id
GROUP BY r.route_code, s1.stop_name, s2.stop_name
ORDER BY pax DESC
LIMIT 15;

