-- Keep a log of any SQL queries you execute as you solve the mystery.
-- Ran the following query to get crime scene reports from around the time of the crime taking place (28/7/21)
SELECT * FROM crime_scene_reports WHERE day > 27 AND month > 6;
-- Crime took place at 10:15am at the Humphrey Street Bakery, three witnesses were interviewed that day and all mentioned the bakery.
--
-- Ran the following query to read the three relevant witness reports.
SELECT * FROM interviews WHERE day > 27 AND month > 6;
-- Ruth said the thief escaped in a car which might be on CCTV footage of the parking lot around that time.
-- Eugene said they recognised the thief, he also saw them earlier that morning on Leggett Street withdrawing some money.
-- Raymond said that as the thief left the bakery, they called someone for less than a minute, saying they're taking the first flight out of Fiftyville tomorrow, asking
-- the person on the phone to get them a plane ticket.
--
-- Ran the following query to check bakery security logs for any relevant license plates and owner's names from cars leaving the poarking lot between 10:15 and 10:25.
SELECT * FROM bakery_security_logs WHERE
year = 2021 AND month  = 7 AND day = 28 AND hour = 10 AND minute > 15 AND minute < 25;
-- Relevant license plates are:
-- -- +-----+------+-------+-----+------+--------+----------+---------------+
-- | id  | year | month | day | hour | minute | activity | license_plate |
-- +-----+------+-------+-----+------+--------+----------+---------------+
-- | 260 | 2021 | 7     | 28  | 10   | 16     | exit     | 5P2BI95       |
-- | 261 | 2021 | 7     | 28  | 10   | 18     | exit     | 94KL13X       |
-- | 262 | 2021 | 7     | 28  | 10   | 18     | exit     | 6P58WS2       |
-- | 263 | 2021 | 7     | 28  | 10   | 19     | exit     | 4328GD8       |
-- | 264 | 2021 | 7     | 28  | 10   | 20     | exit     | G412CB7       |
-- | 265 | 2021 | 7     | 28  | 10   | 21     | exit     | L93JTIZ       |
-- | 266 | 2021 | 7     | 28  | 10   | 23     | exit     | 322W7JE       |
-- | 267 | 2021 | 7     | 28  | 10   | 23     | exit     | 0NTHK55       |
-- +-----+------+-------+-----+------+--------+----------+---------------+
--
-- Ran the following query to check who owned those license plates:
SELECT people.name, people.license_plate FROM bakery_security_logs
JOIN people ON bakery_security_logs.license_plate = people.license_plate
WHERE
year = 2021 AND month  = 7 AND day = 28 AND hour = 10 AND minute > 15 AND minute < 25;
-- +---------+---------------+
-- |  name   | license_plate |
-- +---------+---------------+
-- | Vanessa | 5P2BI95       |
-- | Bruce   | 94KL13X       |
-- | Barry   | 6P58WS2       |
-- | Luca    | 4328GD8       |
-- | Sofia   | G412CB7       |
-- | Iman    | L93JTIZ       |
-- | Diana   | 322W7JE       |
-- | Kelsey  | 0NTHK55       |
-- +---------+---------------+
-- Ran the following query to check ATM withdrawals that morning
SELECT * FROM atm_transactions WHERE year = 2021 AND month = 7 AND day = 28 AND atm_location = "Leggett Street";
-- Then joined this on bank_accounts to find out the person_id and joined on people to find out their name
SELECT people.name, atm_transactions.account_number, atm_transactions.amount
FROM atm_transactions
JOIN bank_accounts ON atm_transactions.account_number = bank_accounts.account_number
JOIN people AS "people" ON people.id = bank_accounts.person_id
WHERE atm_transactions.year = 2021 AND
atm_transactions.month = 7 AND
atm_transactions.day = 28 AND
atm_transactions.atm_location = "Leggett Street";




-- Which yielded the following names and associated account numbers which withdrew money on Leggett Street
-- +---------+----------------+--------+
-- |  name   | account_number | amount |
-- +---------+----------------+--------+
-- | Bruce   | 49610011       | 50     |
-- | Kaelyn  | 86363979       | 10     |
-- | Diana   | 26013199       | 35     |
-- | Brooke  | 16153065       | 80     |
-- | Kenny   | 28296815       | 20     |
-- | Iman    | 25506511       | 20     |
-- | Luca    | 28500762       | 48     |
-- | Taylor  | 76054385       | 60     |
-- | Benista | 81061156       | 30     |
-- +---------+----------------+--------+
--
-- Next ran a query to check phone records immediately after the robbery (10:15am) where the phone call mentioned first flight out of Fiftyville on 29/7/21.
-- This generated this list of calls and the numbers of the callers and receivers
SELECT caller, receiver, duration FROM phone_calls
WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 61
ORDER BY DURATION ASC;
-- +----------------+----------------+----------+
-- |     caller     |    receiver    | duration |
-- +----------------+----------------+----------+
-- | (499) 555-9472 | (892) 555-8872 | 36       |
-- | (031) 555-6622 | (910) 555-3251 | 38       |
-- | (286) 555-6063 | (676) 555-6554 | 43       |
-- | (367) 555-5533 | (375) 555-8161 | 45       |
-- | (770) 555-1861 | (725) 555-3243 | 49       |
-- | (499) 555-9472 | (717) 555-1342 | 50       |
-- | (130) 555-0289 | (996) 555-8899 | 51       |
-- | (338) 555-6650 | (704) 555-2131 | 54       |
-- | (826) 555-1652 | (066) 555-9701 | 55       |
-- | (609) 555-5876 | (389) 555-5198 | 60       |
-- +----------------+----------------+----------+
-- +----------------+----------------+
--
-- Now let's use these on the people table to find out names of callers/receivers
-- First create specific CTE's for callers or receivers to query


WITH callers AS (
    SELECT caller FROM phone_calls
WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 61
ORDER BY DURATION ASC)

SELECT * FROM people WHERE phone_number IN callers;
-- +--------+---------+----------------+-----------------+---------------+
-- |   id   |  name   |  phone_number  | passport_number | license_plate |
-- +--------+---------+----------------+-----------------+---------------+
-- | 395717 | Kenny   | (826) 555-1652 | 9878712108      | 30G67EN       |
-- | 398010 | Sofia   | (130) 555-0289 | 1695452385      | G412CB7       |
-- | 438727 | Benista | (338) 555-6650 | 9586786673      | 8X428L0       |
-- | 449774 | Taylor  | (286) 555-6063 | 1988161715      | 1106N58       |
-- | 514354 | Diana   | (770) 555-1861 | 3592750733      | 322W7JE       |
-- | 560886 | Kelsey  | (499) 555-9472 | 8294398571      | 0NTHK55       |
-- | 561160 | Kathryn | (609) 555-5876 | 6121106406      | 4ZY7I8T       |
-- | 686048 | Bruce   | (367) 555-5533 | 5773159633      | 94KL13X       |
-- | 907148 | Carina  | (031) 555-6622 | 9628244268      | Q12B3Z3       |
-- +--------+---------+----------------+-----------------+---------------+
WITH receivers AS (
    SELECT receiver FROM phone_calls
WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 61
ORDER BY DURATION ASC)

SELECT * FROM people WHERE phone_number IN receivers;
--
-- Receivers
-- +--------+------------+----------------+-----------------+---------------+
-- |   id   |    name    |  phone_number  | passport_number | license_plate |
-- +--------+------------+----------------+-----------------+---------------+
-- | 250277 | James      | (676) 555-6554 | 2438825627      | Q13SVG6       |
-- | 251693 | Larry      | (892) 555-8872 | 2312901747      | O268ZZ0       |
-- | 467400 | Luca       | (389) 555-5198 | 8496433585      | 4328GD8       |
-- | 484375 | Anna       | (704) 555-2131 | NULL            | NULL          |
-- | 567218 | Jack       | (996) 555-8899 | 9029462229      | 52R0Y8U       |
-- | 626361 | Melissa    | (717) 555-1342 | 7834357192      | NULL          |
-- | 712712 | Jacqueline | (910) 555-3251 | NULL            | 43V0R5D       |
-- | 847116 | Philip     | (725) 555-3243 | 3391710505      | GW362R6       |
-- | 864400 | Robin      | (375) 555-8161 | NULL            | 4V16VO0       |
-- | 953679 | Doris      | (066) 555-9701 | 7214083635      | M51FA04       |
-- +--------+------------+----------------+-----------------+---------------+
--
-- Now we can cross reference these license plates of callers to find out who left the bakery and made a relevant atm withdrawal
-- Again we will utilise CTEs to tidy the query up, where 'potential_getaway_cars' contains all license plates of cars that left the bakery after the robbery,
-- 'callers' contains all phone numbers of callers who made calls of less than 60 seconds shortly after the crime, and finally 'atm' which contains IDs of people
-- who made ATM transactions on Leggett Street on the day of the crime (utilising a join on people, bank_accounts and atm_transactions tables).

WITH potential_getaway_cars AS (
    SELECT license_plate FROM bakery_security_logs WHERE
year = 2021 AND month  = 7 AND day = 28 AND hour = 10 AND minute > 15 AND minute < 25)
,
callers AS (
    SELECT caller FROM phone_calls
WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 61
ORDER BY DURATION ASC)
,
atm AS (
    SELECT people.id
FROM people
JOIN bank_accounts ON people.id = bank_accounts.person_id
JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number
WHERE atm_transactions.year = 2021 AND
atm_transactions.month = 7 AND
atm_transactions.day = 28 AND
atm_transactions.atm_location = "Leggett Street"
)

SELECT * FROM people WHERE license_plate IN
potential_getaway_cars
AND phone_number IN
callers AND id IN
atm;
--
-- This generated these people, who withdrew money on Leggett Street that morning, left the bakery shortly after the robbery and were on phone for
-- less than a minute shortly after also.
-- +--------+-------+----------------+-----------------+---------------+
-- |   id   | name  |  phone_number  | passport_number | license_plate |
-- +--------+-------+----------------+-----------------+---------------+
-- | 514354 | Diana | (770) 555-1861 | 3592750733      | 322W7JE       |
-- | 686048 | Bruce | (367) 555-5533 | 5773159633      | 94KL13X       |
-- +--------+-------+----------------+-----------------+---------------+
--
-- Next it would make sense to check these two names against the passenger names on the first flight out the day after the robbery.
-- First we need to find out what the first flight was out of Fifytville;
SELECT * FROM flights
WHERE year = 2021 AND month = 7 AND day = 29
ORDER BY hour ASC
LIMIT 1;
-- This query shows us that the first flight was the 8:20
-- +----+-------------------+------------------------+------+-------+-----+------+--------+
-- | id | origin_airport_id | destination_airport_id | year | month | day | hour | minute |
-- +----+-------------------+------------------------+------+-------+-----+------+--------+
-- | 36 | 8                 | 4                      | 2021 | 7     | 29  | 8    | 20     |
-- | 43 | 8                 | 1                      | 2021 | 7     | 29  | 9    | 30     |
-- | 23 | 8                 | 11                     | 2021 | 7     | 29  | 12   | 15     |
-- | 53 | 8                 | 9                      | 2021 | 7     | 29  | 15   | 20     |
-- | 18 | 8                 | 6                      | 2021 | 7     | 29  | 16   | 0      |
-- +----+-------------------+------------------------+------+-------+-----+------+--------+
--
-- Let's join these on passengers table to find out if any of our three suspects are on that flight
WITH first_flight AS (
    SELECT id FROM flights
WHERE year = 2021 AND month = 7 AND day = 29
ORDER BY hour ASC
LIMIT 1
)
SELECT passport_number FROM passengers WHERE flight_id IN
first_flight;
--
-- Now let's cross reference this with our list of people
WITH potential_getaway_cars AS (
    SELECT license_plate FROM bakery_security_logs WHERE
year = 2021 AND month  = 7 AND day = 28 AND hour = 10 AND minute > 15 AND minute < 25)
,
callers AS (
    SELECT caller FROM phone_calls
WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 61
ORDER BY DURATION ASC)
,
atm AS (
    SELECT people.id
FROM people
JOIN bank_accounts ON people.id = bank_accounts.person_id
JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number
WHERE atm_transactions.year = 2021 AND
atm_transactions.month = 7 AND
atm_transactions.day = 28 AND
atm_transactions.atm_location = "Leggett Street"
),
first_flight AS (
    SELECT id FROM flights
WHERE year = 2021 AND month = 7 AND day = 29
ORDER BY hour ASC
LIMIT 1
)
SELECT name FROM people WHERE passport_number IN
(SELECT passport_number FROM passengers WHERE flight_id IN
first_flight)
AND name IN
(SELECT name FROM people WHERE license_plate IN
potential_getaway_cars
AND phone_number IN
callers AND id IN
atm);
-- +-------+
-- | name  |
-- +-------+
-- | Bruce |
-- +-------+
--
-- Now to find Bruce's accomplice:
-- For this it makes sense to check who Bruce called
WITH Bruce_call_receiver AS
(SELECT receiver FROM phone_calls
WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 61
AND caller IN
(SELECT phone_number FROM people WHERE name = "Bruce"))

SELECT name AS "Accomplice" FROM people WHERE phone_number IN Bruce_call_receiver;
--
-- +------------+
-- | Accomplice |
-- +------------+
-- | Robin      |
-- +------------+
--
-- And finally we need to check which city Bruce escaped to
WITH first_flight AS (
    SELECT destination_airport_id FROM flights
WHERE year = 2021 AND month = 7 AND day = 29
ORDER BY hour ASC
LIMIT 1
)

SELECT city FROM airports WHERE id IN first_flight;
-- +---------------+
-- |     city      |
-- +---------------+
-- | New York City |
-- +---------------+