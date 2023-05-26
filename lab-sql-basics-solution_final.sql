use bank;

-- Query 1

select client_id as client 
from client
where district_id = 1
limit 5;

-- Query 2

select client_id as client 
from client
where district_id = 72
order by client_id desc
limit 1;

-- Query 3

select amount as amount
from loan
order by amount asc
limit 3;

-- Query 4

select distinct(status)
from loan
order by status asc;

-- Query 5

select loan_id
from loan
order by payments asc
limit 1;

-- Query 6

select account_id, amount
from loan
order by account_id asc
limit 5;

-- Query 7

select account_id 
from loan
where duration = 60
order by amount asc
limit 5;

-- Query 8

select distinct(k_symbol)
from `order`
order by k_symbol;

-- Query 9

select order_id
from `order`
where account_id = 34;

-- Query 10

select distinct(account_id)
from `order`
where order_id > 29540 and order_id < 29560;

-- or

select distinct(account_id)
from `order`
where order_id between 29540 and 29560;

-- Query 11

select amount
from `order`
where account_to = '30067122';

-- Query 12

select trans_id, date, type, amount 
from trans
where account_id = 793
order by date desc
limit 10;

-- Query 13

select district_id, count(client_id)
from client
where district_id < 10
group by district_id
order by district_id asc;

-- Query 14

select type, count(card_id)
from card
group by type
order by count(card_id) desc;

-- Query 15

select account_id, sum(amount) as 'total amount'
from loan
group by account_id
order by sum(amount) desc
limit 10;

-- Query 16

select date, count(loan_id)
from loan
where date < '930907'
group by date
order by date desc;

-- Query 17

select date, duration, count(loan_id)
from loan
where date regexp '9712'
group by date, duration
order by date asc, duration asc;

-- Query 18

select account_id, type, sum(amount) as total_amount
from trans 
where account_id = 396
group by type
order by type;

-- Query 19

select account_id, 
case 
when type = 'PRIJEM' then 'Incoming'
when type = 'VYDAJ' then 'Outgoing'
end
as transaction_type, round(sum(amount),0) as total_amount
from trans
where account_id = 396
group by type
order by type;

-- Query 20

-- subquery to get the sum of incoming
select round(sum(amount),0) as incoming
from trans
where type = 'PRIJEM' and account_id = 396
group by type;

-- subquery to get the sum of outgoing
select round(sum(amount),0) as outgoing
from trans
where type = 'VYDAJ' and account_id = 396
group by type;

-- subquery to save those sums under aliases
select account_id,
(select round(sum(amount),0)
where type = 'PRIJEM'
group by type) as incoming, 
(select round(sum(amount),0)
where type = 'VYDAJ'
group by type) as outgoing
from trans
where account_id = 396
group by type;

-- subquery to save those sums under aliases but without nulls
select account_id,
case 
when (select round(sum(amount),0) where type = 'PRIJEM' group by type) is null then 0 else (select round(sum(amount),0) where type = 'PRIJEM' group by type) end 
as incoming, 
case 
when (select round(sum(amount),0) where type = 'VYDAJ' group by type) is null then 0 else (select round(sum(amount),0) where type = 'VYDAJ' group by type) end 
as outgoing
from trans
where account_id = 396
group by type;

-- FINAL ANSWER: query to display account_id with balance information
select account_id, concat(sum(incoming), ' ',  sum(outgoing), ' ', (sum(incoming)-sum(outgoing))) as balance
from (
	select account_id,
	case 
	when (select round(sum(amount),0) where type = 'PRIJEM' group by type) is null then 0 else (select round(sum(amount),0) where type = 'PRIJEM' group by type) end 
	as incoming, 
	case 
	when (select round(sum(amount),0) where type = 'VYDAJ' group by type) is null then 0 else (select round(sum(amount),0) where type = 'VYDAJ' group by type) end 
	as outgoing
	from trans
	where account_id = 396
	group by type
	)	
	as sums
group by account_id;

 -- Query 21

-- subquery to get the sum of incoming for all account_ids
select account_id, round(sum(amount),0) as incoming
from trans
where type = 'PRIJEM' 
group by account_id, type;

-- subquery to get the sum of outgoing for all account_ids
select account_id, round(sum(amount),0) as outgoing
from trans
where type = 'VYDAJ'
group by account_id, type; 

-- subquery to save those sums under aliases and without nulls:
select account_id,
case 
when (select round(sum(amount),0) where type = 'PRIJEM' group by type) is null then 0 else (select round(sum(amount),0) where type = 'PRIJEM' group by type) end 
as incoming, 
case 
when (select round(sum(amount),0) where type = 'VYDAJ' group by type) is null then 0 else (select round(sum(amount),0) where type = 'VYDAJ' group by type) end 
as outgoing
from trans
group by account_id, type
order by account_id asc;

-- FINAL ANSWER: query to display account_id with balance information
select account_id, (sum(incoming)-sum(outgoing)) as total_balance
from (
	select account_id,
	case 
	when (select round(sum(amount),0) where type = 'PRIJEM' group by type) is null then 0 else (select round(sum(amount),0) where type = 'PRIJEM' group by type) end 
	as incoming, 
	case 
	when (select round(sum(amount),0) where type = 'VYDAJ' group by type) is null then 0 else (select round(sum(amount),0) where type = 'VYDAJ' group by type) end 
	as outgoing
	from trans
	group by account_id, type
	)	
	as sums
group by account_id
order by total_balance desc
limit 10;
 