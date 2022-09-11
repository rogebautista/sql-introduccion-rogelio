--create database keepcoding;
-- drop database keepcoding2;
/*CREATE DATABASE "keepcodingRogelio"
WITH OWNER "postgres"
ENCODING 'UTF8'
LC_COLLATE = 'es-MX'
LC_CTYPE = 'es-MX'
TEMPLATE template0;
*/

/* Create schema */

-- create schema if not exists practica;
drop schema if exists practica cascade ;

create schema if not exists practica;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


/* Table generation*/
-- drop table if exists practica.vehicle_commercial_group cascade ;
create table if not exists practica.vehicle_commercial_group
(
    id_vehicle_commercial_group uuid DEFAULT uuid_generate_v1 ()       not null unique
        constraint vehicle_commercial_group_pk
            primary key,
    group_name                  varchar(60) not null,
    description                 varchar(500),
    created_at                  timestamp with time zone not null,
    updated_at                  timestamp with time zone not null,
    is_available                boolean not null,
    is_enabled                  boolean not null
);


create table if not exists practica.vehicle_brand
(
    id_vehicle_brand uuid DEFAULT uuid_generate_v1 ()        not null unique
        constraint vehicle_brand_pk
            primary key,
    brand_name                  varchar(60) not null,
    description                 varchar(500),
    vehicle_commercial_group_id uuid not null,
    created_at                  timestamp with time zone not null,
    updated_at                  timestamp with time zone not null,
    is_available                boolean not null,
    is_enabled                  boolean not null
);

alter table practica.vehicle_brand drop constraint if exists vechicle_brand_vehicle_commercial_group_fk;
ALTER TABLE practica.vehicle_brand
ADD CONSTRAINT vechicle_brand_vehicle_commercial_group_fk
FOREIGN KEY (vehicle_commercial_group_id)
REFERENCES practica.vehicle_commercial_group (id_vehicle_commercial_group);


create table if not exists practica.vehicle_model(
    id_vehicle_model uuid DEFAULT uuid_generate_v1 () not null unique
        constraint vehicle_model_pk primary key,
    model_name varchar(60) not null,
    description varchar(500),
    vehicle_brand_id uuid not null,
    created_at timestamptz not null ,
    updated_at timestamptz not null,
    is_available boolean not null,
    is_enabled boolean not null
);

alter table practica.vehicle_model drop constraint if exists vehicle_model_vehicle_brand_fk;
alter table if exists practica.vehicle_model
add constraint vehicle_model_vehicle_brand_fk
foreign key (vehicle_brand_id)
references practica.vehicle_brand (id_vehicle_brand);



create table if not exists practica.insurance_carrier(
    id_insurance_carrier uuid DEFAULT uuid_generate_v1 () not null unique
        constraint insurance_carrier_pk primary key,
    insurance_carrier_name varchar(60) not null,
    description varchar(500),
    created_at timestamptz,
    updated_at timestamptz,
    is_available boolean not null,
    is_enabled boolean not null
);


create table if not exists practica.vehicle_policy(
    id_vehicle_policy uuid DEFAULT uuid_generate_v1 () not null unique
        constraint vehicle_policy_pk primary key,
    insurance_carrier_id uuid not null,
    policy_number varchar(60) not null,
    adquisition_date timestamptz not null,
    created_at timestamptz not null,
    updated_at timestamptz not null,
    is_enabled boolean not null,
    is_available boolean not null,
    updated_by uuid null,
    end_of_policy timestamptz
);

alter table practica.vehicle_policy drop constraint if exists vehicle_policy_insurance_carrier_fk;
alter table practica.vehicle_policy
add constraint vehicle_policy_insurance_carrier_fk
foreign key (insurance_carrier_id)
references practica.insurance_carrier (id_insurance_carrier);



create table if not exists practica.vehicle(
    id_vehicle uuid DEFAULT uuid_generate_v1 () not null unique
        constraint vehicle_pk primary key,
    vehicle_model_id uuid not null ,
    vehicle_registration varchar(20) not null,
    vehicle_policy_id uuid not null,
    adquisition_date timestamptz not null,
    created_at timestamptz not null,
    updated_at timestamptz not null,
    updated_by uuid null,
    is_available boolean not null,
    is_enabled boolean not null,
    color_name varchar(50) not null,
    hex_code_color varchar(15) not null
);

alter table practica.vehicle drop constraint if exists vehicle_vehicle_model_fk;
alter table if exists practica.vehicle
add constraint vehicle_vehicle_model_fk
foreign key (vehicle_model_id)
references practica.vehicle_model (id_vehicle_model);

alter table practica.vehicle drop constraint if exists vehicle_vehicle_policy_fk;
alter table if exists practica.vehicle
add constraint vehicle_vehicle_policy_fk
foreign key (vehicle_policy_id)
references practica.vehicle_policy (id_vehicle_policy);

create table if not exists practica.currency(
    id_currency uuid default uuid_generate_v1() not null unique
        constraint currency_pk primary key ,
    currency_name varchar(30) not null,
    symbol varchar(10) not null
);

create table if not exists practica.revisions(
    id_revision uuid DEFAULT uuid_generate_v1 () not null unique
        constraint revisions_pk primary key,
    vehicle_id uuid not null,
    date_revision timestamptz not null,
    kilometers numeric(12,5) not null,
    revision_cost numeric(12,5) not null,
    currency_id uuid not null,
    created_at timestamptz not null,
    updated_at timestamptz not null,
    updated_by uuid null,
    is_available boolean not null,
    is_enabled boolean not null

);

alter table practica.revisions drop constraint if exists revisions_vehicle_fk;
alter table if exists practica.revisions
add constraint revisions_vehicle_fk
foreign key (vehicle_id)
references practica.vehicle (id_vehicle);

alter table practica.revisions drop constraint if exists revisions_currency_fk;
alter table if exists practica.revisions
add constraint revisions_currency_fk
foreign key (currency_id)
references practica.currency (id_currency);


/* Infomación*/



-- select array_agg(group_name) from practica.vehicle_commercial_group;

-- delete from practica.vehicle_brand;

/* Esto se realizo para poder llenar de forma rápida las marcas */
/*
do $$
    declare
        vehicle_commercial_group_id_aleatorio uuid;
        vehicle_commercial_group_id_position uuid;
        vehicle_commercial_group_array uuid[] DEFAULT  ARRAY[]::uuid[];
        vehicle_brand_name varchar;

        vehicle_model_bmw_array varchar[] DEFAULT  ARRAY['Mini','Rolls Roice','BMW']::varchar[];
        vehicle_model_daimler_array varchar[] DEFAULT  ARRAY['Maybach','Mercedes-Benz','Smart']::varchar[];
        vehicle_model_fca_array varchar[] DEFAULT  ARRAY['Alfa Romeo','Abarth','Chrysler','Dodge','Fiat','Jeep','Lancia','Maserati','RAM']::varchar[];
        vehicle_model_ferrari_array varchar[] DEFAULT  ARRAY['Ferrary','Ferrary']::varchar[];
        vehicle_model_ford_array varchar[] DEFAULT  ARRAY['Ford','The Lincoln Company','Troller']::varchar[];
        vehicle_model_geely_array varchar[] DEFAULT  ARRAY['Geely','The London Taxi Company','Volvo']::varchar[];
        vehicle_model_gm_array varchar[] DEFAULT  ARRAY['Baojun','Buick','Cadillac','Chevrolet','GMC','Wuling Motors']::varchar[];
        vehicle_model_honda_array varchar[] DEFAULT  ARRAY['Acura','Honda']::varchar[];
        vehicle_model_hyundai_array varchar[] DEFAULT  ARRAY['Kia','Hyundai','Genesis']::varchar[];
        vehicle_model_nissanmc_array varchar[] DEFAULT  ARRAY['Renault','Nissan','Infinity','Mitsubishi','Alpine','Datsun']::varchar[];
        vehicle_model_psa_array varchar[] DEFAULT  ARRAY['Peugeot','Opel','DS Automoviles','Citroën']::varchar[];
        vehicle_model_suzuki_array varchar[] DEFAULT  ARRAY['Suzuki','Suzuki']::varchar[];
        vehicle_model_tata_array varchar[] DEFAULT  ARRAY['Jaguar','Land Rover','Tata Motors']::varchar[];
        vehicle_model_toyota_array varchar[] DEFAULT  ARRAY['Toyota','Lexus','Daihatsu']::varchar[];
        vehicle_model_volkswagwn_array varchar[] DEFAULT  ARRAY['Audi','Bentley','Bugatti','Lamborghini','Porsche','SEAT','Skoda','Volkswagen']::varchar[];

    begin
        raise notice 'Inicia';
        select into vehicle_commercial_group_array array_agg(id_vehicle_commercial_group) from practica.vehicle_commercial_group;
        raise notice 'Se almacenaron %', array_to_string(vehicle_commercial_group_array,',');
        foreach vehicle_commercial_group_id_position in array vehicle_commercial_group_array
        loop
            SELECT into vehicle_commercial_group_id_aleatorio practica.vehicle_commercial_group.id_vehicle_commercial_group
            FROM practica.vehicle_commercial_group OFFSET floor(random()* (select count(*) from practica.vehicle_commercial_group)) LIMIT 1;

            if vehicle_commercial_group_id_aleatorio = '260b6d70-31da-11ed-9f01-bf7a6eda4fff'::uuid then
                for cnt in 1..ARRAY_LENGTH(vehicle_model_daimler_array,1)
                        loop
                    raise notice 'cont %', cnt;
                            select into vehicle_brand_name (vehicle_model_daimler_array)[floor(random() * 3 + 1)];
                            insert into practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at,
                                       updated_at, is_available, is_enabled)
                            values (uuid_generate_v1(),vehicle_brand_name,'',vehicle_commercial_group_id_aleatorio::uuid, now(), now(),true, true);
                        end loop;
            elsif vehicle_commercial_group_id_aleatorio = '260b6d71-31da-11ed-9f01-bf7a6eda4fff'::uuid then
                for cnt in 1..ARRAY_LENGTH(vehicle_model_fca_array,1)
                loop
                    raise notice 'cont %', cnt;
                                select into vehicle_brand_name (vehicle_model_fca_array)[floor(random() * 3 + 1)];
                                insert into practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at,
                                           updated_at, is_available, is_enabled)
                                values (uuid_generate_v1(), vehicle_brand_name,'',vehicle_commercial_group_id_aleatorio::uuid, now(), now(),true, true);
                end loop;
            elsif vehicle_commercial_group_id_aleatorio = '260b6d72-31da-11ed-9f01-bf7a6eda4fff'::uuid then
                for cnt in 1..ARRAY_LENGTH(vehicle_model_ferrari_array,1)
                            loop
                    raise notice 'cont %', cnt;
                                select into vehicle_brand_name (vehicle_model_ferrari_array)[floor(random() * 3 + 1)];
                                insert into practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at,
                                           updated_at, is_available, is_enabled)
                                values (uuid_generate_v1(), vehicle_brand_name,'',vehicle_commercial_group_id_aleatorio::uuid, now(), now(),true, true);
                            end loop;
            elsif vehicle_commercial_group_id_aleatorio = '260b6d73-31da-11ed-9f01-bf7a6eda4fff'::uuid then
                for cnt in 1..ARRAY_LENGTH(vehicle_model_ford_array,1)
                            loop
                    raise notice 'cont %', cnt;
                                select into vehicle_brand_name (vehicle_model_ford_array)[floor(random() * 3 + 1)];
                                insert into practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at,
                                           updated_at, is_available, is_enabled)
                                values (uuid_generate_v1(), vehicle_brand_name,'',vehicle_commercial_group_id_aleatorio::uuid, now(), now(),true, true);
                            end loop;
            elsif vehicle_commercial_group_id_aleatorio = '260b6d74-31da-11ed-9f01-bf7a6eda4fff'::uuid then
                for cnt in 1..ARRAY_LENGTH(vehicle_model_geely_array,1)
                            loop
                    raise notice 'cont %', cnt;
                                select into vehicle_brand_name (vehicle_model_geely_array)[floor(random() * 3 + 1)];
                                insert into practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at,
                                           updated_at, is_available, is_enabled)
                                values (uuid_generate_v1(), vehicle_brand_name,'',vehicle_commercial_group_id_aleatorio::uuid, now(), now(),true, true);
                            end loop;
            elsif vehicle_commercial_group_id_aleatorio = '26d34757-31da-11ed-9f01-bf7a6eda4fff'::uuid then
                for cnt in 1..ARRAY_LENGTH(vehicle_model_volkswagwn_array,1)
                            loop
                    raise notice 'cont %', cnt;
                                select into vehicle_brand_name (vehicle_model_volkswagwn_array)[floor(random() * 3 + 1)];
                                insert into practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at,
                                           updated_at, is_available, is_enabled)
                                values (uuid_generate_v1(), vehicle_brand_name,'',vehicle_commercial_group_id_aleatorio::uuid, now(), now(),true, true);
                            end loop;
            end if;
        end loop;

    end

    $$;

*/

INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('260b6d70-31da-11ed-9f01-bf7a6eda4fff', 'Daimler', null, '2022-09-11 08:54:19.114000 +00:00', '2022-09-11 08:54:22.298000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('260b6d71-31da-11ed-9f01-bf7a6eda4fff', 'FCA', 'Fiat Chrysler Automobiles', '2022-09-11 08:54:55.302000 +00:00', '2022-09-11 08:54:59.275000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('260b6d72-31da-11ed-9f01-bf7a6eda4fff', 'Ferrari', null, '2022-09-11 08:55:27.460000 +00:00', '2022-09-11 08:55:30.420000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('260b6d73-31da-11ed-9f01-bf7a6eda4fff', 'Ford', null, '2022-09-11 08:55:51.128000 +00:00', '2022-09-11 08:55:54.650000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('260b6d74-31da-11ed-9f01-bf7a6eda4fff', 'Geely', null, '2022-09-11 08:56:28.012000 +00:00', '2022-09-11 08:56:31.180000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('260b6d75-31da-11ed-9f01-bf7a6eda4fff', 'GM', 'General Motors', '2022-09-11 08:57:04.997000 +00:00', '2022-09-11 08:57:08.665000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('26d34750-31da-11ed-9f01-bf7a6eda4fff', 'Honda', null, '2022-09-11 08:57:24.381000 +00:00', '2022-09-11 08:57:28.006000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('26d34751-31da-11ed-9f01-bf7a6eda4fff', 'Hyundai', null, '2022-09-11 08:57:54.553000 +00:00', '2022-09-11 08:57:57.202000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('26d34752-31da-11ed-9f01-bf7a6eda4fff', 'Renault Nissan', null, '2022-09-11 08:58:26.021000 +00:00', '2022-09-11 08:58:28.630000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('26d34753-31da-11ed-9f01-bf7a6eda4fff', 'PSA', null, '2022-09-11 08:59:07.857000 +00:00', '2022-09-11 08:59:10.686000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('26d34754-31da-11ed-9f01-bf7a6eda4fff', 'Suzuki', null, '2022-09-11 08:59:35.783000 +00:00', '2022-09-11 08:59:38.650000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('26d34755-31da-11ed-9f01-bf7a6eda4fff', 'Tata', null, '2022-09-11 08:59:53.222000 +00:00', '2022-09-11 08:59:56.033000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('26d34756-31da-11ed-9f01-bf7a6eda4fff', 'Toyota', null, '2022-09-11 09:00:19.130000 +00:00', '2022-09-11 09:00:22.026000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('26d34757-31da-11ed-9f01-bf7a6eda4fff', 'Volkswagen', null, '2022-09-11 09:00:37.828000 +00:00', '2022-09-11 09:00:40.454000 +00:00', true, true);
INSERT INTO practica.vehicle_commercial_group (id_vehicle_commercial_group, group_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('a62e858e-31d8-11ed-9f01-bf7a6eda4fff', 'BMW', 'Bayerische Motores Werke', '2022-09-11 08:49:54.106000 +00:00', '2022-09-11 08:49:56.987000 +00:00', true, true);


INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('393124e4-320c-11ed-aa57-708bcd076c78', 'Ferrary', '', '260b6d72-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 19:59:19.886094 +00:00', '2022-09-11 19:59:19.886094 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('39314d5d-320c-11ed-aa59-708bcd076c78', 'Smart', '', '260b6d70-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 19:59:19.886094 +00:00', '2022-09-11 19:59:19.886094 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('3931730e-320c-11ed-aa5b-708bcd076c78', 'Mercedes-Benz', '', '260b6d70-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 19:59:19.886094 +00:00', '2022-09-11 19:59:19.886094 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('414e73ca-320c-11ed-aa5c-708bcd076c78', 'Alfa Romeo', '', '260b6d71-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 19:59:33.499012 +00:00', '2022-09-11 19:59:33.499012 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('414e9ac6-320c-11ed-aa5e-708bcd076c78', 'Chrysler', '', '260b6d71-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 19:59:33.499012 +00:00', '2022-09-11 19:59:33.499012 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('414e9ac8-320c-11ed-aa60-708bcd076c78', 'Abarth', '', '260b6d71-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 19:59:33.499012 +00:00', '2022-09-11 19:59:33.499012 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('414ec1cd-320c-11ed-aa66-708bcd076c78', 'Maybach', '', '260b6d70-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 19:59:33.499012 +00:00', '2022-09-11 19:59:33.499012 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('b62f5ca4-320c-11ed-aa74-708bcd076c78', 'Bentley', '', '26d34757-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 20:02:49.587359 +00:00', '2022-09-11 20:02:49.587359 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('b62f5ca5-320c-11ed-aa75-708bcd076c78', 'Bugatti', '', '26d34757-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 20:02:49.587359 +00:00', '2022-09-11 20:02:49.587359 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('b62f5ca6-320c-11ed-aa76-708bcd076c78', 'Audi', '', '26d34757-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 20:02:49.587359 +00:00', '2022-09-11 20:02:49.587359 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('b62ff8ee-320c-11ed-aa8c-708bcd076c78', 'The London Taxi Company', '', '260b6d74-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 20:02:49.587359 +00:00', '2022-09-11 20:02:49.587359 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('b62ff8ef-320c-11ed-aa8d-708bcd076c78', 'Geely', '', '260b6d74-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 20:02:49.587359 +00:00', '2022-09-11 20:02:49.587359 +00:00', true, true);
INSERT INTO practica.vehicle_brand (id_vehicle_brand, brand_name, description, vehicle_commercial_group_id, created_at, updated_at, is_available, is_enabled) VALUES ('b62ff8f0-320c-11ed-aa8e-708bcd076c78', 'Volvo', '', '260b6d74-31da-11ed-9f01-bf7a6eda4fff', '2022-09-11 20:02:49.587359 +00:00', '2022-09-11 20:02:49.587359 +00:00', true, true);


INSERT INTO practica.vehicle_model (id_vehicle_model, model_name, description, vehicle_brand_id, created_at, updated_at, is_available, is_enabled) VALUES ('c8216320-320d-11ed-8fd6-708bcd076c78', 'Mercedes-Benz S-Class', null, '3931730e-320c-11ed-aa5b-708bcd076c78', '2022-09-11 15:05:37.959000 +00:00', '2022-09-11 15:05:42.332000 +00:00', true, true);
INSERT INTO practica.vehicle_model (id_vehicle_model, model_name, description, vehicle_brand_id, created_at, updated_at, is_available, is_enabled) VALUES ('c824222c-320d-11ed-8fd7-708bcd076c78', 'Mercedes-Benz C-Class', null, '3931730e-320c-11ed-aa5b-708bcd076c78', '2022-09-11 15:06:29.594000 +00:00', '2022-09-11 15:06:31.289000 +00:00', true, true);
INSERT INTO practica.vehicle_model (id_vehicle_model, model_name, description, vehicle_brand_id, created_at, updated_at, is_available, is_enabled) VALUES ('c82533ba-320d-11ed-8fd8-708bcd076c78', 'Maybach 57 and 62', null, '414ec1cd-320c-11ed-aa66-708bcd076c78', '2022-09-11 15:07:18.215000 +00:00', '2022-09-11 15:07:20.489000 +00:00', true, true);
INSERT INTO practica.vehicle_model (id_vehicle_model, model_name, description, vehicle_brand_id, created_at, updated_at, is_available, is_enabled) VALUES ('c8261e88-320d-11ed-8fd9-708bcd076c78', 'Smart Fortwo', null, '39314d5d-320c-11ed-aa59-708bcd076c78', '2022-09-11 15:08:01.046000 +00:00', '2022-09-11 15:08:02.964000 +00:00', true, true);
INSERT INTO practica.vehicle_model (id_vehicle_model, model_name, description, vehicle_brand_id, created_at, updated_at, is_available, is_enabled) VALUES ('c8272f94-320d-11ed-8fda-708bcd076c78', 'Smart Roadster', null, '39314d5d-320c-11ed-aa59-708bcd076c78', '2022-09-11 15:08:17.674000 +00:00', '2022-09-11 15:08:16.150000 +00:00', true, true);
INSERT INTO practica.vehicle_model (id_vehicle_model, model_name, description, vehicle_brand_id, created_at, updated_at, is_available, is_enabled) VALUES ('c82840e6-320d-11ed-8fdb-708bcd076c78', 'Volvo V70/XC70', null, 'b62ff8f0-320c-11ed-aa8e-708bcd076c78', '2022-09-11 15:09:35.866000 +00:00', '2022-09-11 15:09:37.333000 +00:00', true, true);
INSERT INTO practica.vehicle_model (id_vehicle_model, model_name, description, vehicle_brand_id, created_at, updated_at, is_available, is_enabled) VALUES ('c8295260-320d-11ed-8fdc-708bcd076c78', 'Audi A1', null, 'b62f5ca6-320c-11ed-aa76-708bcd076c78', '2022-09-11 15:10:12.000000 +00:00', '2022-09-11 15:10:13.772000 +00:00', true, true);


INSERT INTO practica.insurance_carrier (id_insurance_carrier, insurance_carrier_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('ad2c250e-320e-11ed-93d3-708bcd076c78', 'MetLife', 'metlife', '2022-09-11 15:13:34.508000 +00:00', '2022-09-11 15:13:36.286000 +00:00', true, true);
INSERT INTO practica.insurance_carrier (id_insurance_carrier, insurance_carrier_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('ad2e1198-320e-11ed-93d4-708bcd076c78', 'Chubb', null, '2022-09-11 15:14:05.372000 +00:00', '2022-09-11 15:14:06.392000 +00:00', true, true);
INSERT INTO practica.insurance_carrier (id_insurance_carrier, insurance_carrier_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('ad2f215a-320e-11ed-93d5-708bcd076c78', 'AXA', null, '2022-09-11 15:16:12.660000 +00:00', '2022-09-11 15:16:14.964000 +00:00', true, true);
INSERT INTO practica.insurance_carrier (id_insurance_carrier, insurance_carrier_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('ad2fe450-320e-11ed-93d6-708bcd076c78', 'Munich Re', null, '2022-09-11 15:16:30.439000 +00:00', '2022-09-11 15:16:31.894000 +00:00', true, true);
INSERT INTO practica.insurance_carrier (id_insurance_carrier, insurance_carrier_name, description, created_at, updated_at, is_available, is_enabled) VALUES ('ad311ce4-320e-11ed-93d7-708bcd076c78', 'Mapfre', null, '2022-09-11 15:16:45.541000 +00:00', '2022-09-11 15:16:47.485000 +00:00', true, true);

INSERT INTO practica.vehicle_policy (id_vehicle_policy, insurance_carrier_id, policy_number, adquisition_date, created_at, updated_at, is_enabled, is_available, updated_by, end_of_policy) VALUES ('e4faa8ca-320e-11ed-80ef-708bcd076c78', 'ad2c250e-320e-11ed-93d3-708bcd076c78', '1qsdfgbnm', '2022-09-11 15:17:47.388000 +00:00', '2022-09-11 15:17:50.656000 +00:00', '2022-09-11 15:17:52.365000 +00:00', true, true, null, '2024-09-11 15:20:43.281000 +00:00');
INSERT INTO practica.vehicle_policy (id_vehicle_policy, insurance_carrier_id, policy_number, adquisition_date, created_at, updated_at, is_enabled, is_available, updated_by, end_of_policy) VALUES ('1cb37198-320f-11ed-80f1-708bcd076c78', 'ad2e1198-320e-11ed-93d4-708bcd076c78', 'ad2e1198-320e-11ed-93d4', '2022-09-11 15:19:36.079000 +00:00', '2022-09-11 15:19:37.865000 +00:00', '2022-09-11 15:19:38.870000 +00:00', true, false, null, '2022-09-10 15:20:52.020000 +00:00');
INSERT INTO practica.vehicle_policy (id_vehicle_policy, insurance_carrier_id, policy_number, adquisition_date, created_at, updated_at, is_enabled, is_available, updated_by, end_of_policy) VALUES ('fce7795e-320e-11ed-80f0-708bcd076c78', 'ad2e1198-320e-11ed-93d4-708bcd076c78', 'ad2e1198-320e-11ed-93d4', '2022-09-11 15:19:00.024000 +00:00', '2022-09-11 15:18:41.814000 +00:00', '2022-09-11 15:18:36.965000 +00:00', true, true, null, '2024-09-11 15:20:48.552000 +00:00');

INSERT INTO practica.vehicle (id_vehicle, vehicle_model_id, vehicle_registration, vehicle_policy_id, adquisition_date, created_at, updated_at, updated_by, is_available, is_enabled, color_name, hex_code_color) VALUES ('9da2f726-3212-11ed-aa85-708bcd076c78', 'c82533ba-320d-11ed-8fd8-708bcd076c78', 'IHT7693', '1cb37198-320f-11ed-80f1-708bcd076c78', '2016-09-11 15:44:35.540000 +00:00', '2016-09-11 15:44:47.369000 +00:00', '2017-09-11 15:44:51.952000 +00:00', null, false, true, 'Blanco', '#ffffff');
INSERT INTO practica.vehicle (id_vehicle, vehicle_model_id, vehicle_registration, vehicle_policy_id, adquisition_date, created_at, updated_at, updated_by, is_available, is_enabled, color_name, hex_code_color) VALUES ('9f79f0ca-320f-11ed-aa83-708bcd076c78', 'c8216320-320d-11ed-8fd6-708bcd076c78', 'YPZ4418', 'e4faa8ca-320e-11ed-80ef-708bcd076c78', '2019-09-11 15:21:39.250000 +00:00', '2019-09-11 15:21:42.686000 +00:00', '2022-09-11 15:21:46.138000 +00:00', null, true, true, 'Azul rey', '#3857CB');
INSERT INTO practica.vehicle (id_vehicle, vehicle_model_id, vehicle_registration, vehicle_policy_id, adquisition_date, created_at, updated_at, updated_by, is_available, is_enabled, color_name, hex_code_color) VALUES ('9f7b9e52-320f-11ed-aa84-708bcd076c78', 'c82840e6-320d-11ed-8fdb-708bcd076c78', 'ERG6578', 'fce7795e-320e-11ed-80f0-708bcd076c78', '2020-09-11 15:22:27.814000 +00:00', '2020-09-11 15:22:31.954000 +00:00', '2021-09-11 15:22:34.679000 +00:00', null, true, true, 'Verde agua', '#66C49F');

INSERT INTO practica.currency (id_currency, currency_name, symbol) VALUES ('f56085a8-320f-11ed-8831-708bcd076c78', 'Euro', '€');
INSERT INTO practica.currency (id_currency, currency_name, symbol) VALUES ('f561e5e2-320f-11ed-8832-708bcd076c78', 'Mexican Peso', '$');
INSERT INTO practica.currency (id_currency, currency_name, symbol) VALUES ('f5628272-320f-11ed-8833-708bcd076c78', 'USD', '$');
INSERT INTO practica.currency (id_currency, currency_name, symbol) VALUES ('f5631dc2-320f-11ed-8834-708bcd076c78', 'Sterling', '£');

INSERT INTO practica.revisions (id_revision, vehicle_id, date_revision, kilometers, revision_cost, currency_id, created_at, updated_at, updated_by, is_available, is_enabled) VALUES ('00036ede-3211-11ed-9b6f-708bcd076c78', '9f79f0ca-320f-11ed-aa83-708bcd076c78', '2022-01-11 15:27:00.157000 +00:00', 4500.00000, 350.00000, 'f56085a8-320f-11ed-8831-708bcd076c78', '2022-01-11 15:27:48.673000 +00:00', '2022-01-11 15:27:54.287000 +00:00', null, true, true);
INSERT INTO practica.revisions (id_revision, vehicle_id, date_revision, kilometers, revision_cost, currency_id, created_at, updated_at, updated_by, is_available, is_enabled) VALUES ('00062e12-3211-11ed-9b70-708bcd076c78', '9f79f0ca-320f-11ed-aa83-708bcd076c78', '2022-02-11 15:28:50.497000 +00:00', 5200.00000, 268.95000, 'f56085a8-320f-11ed-8831-708bcd076c78', '2022-02-11 15:29:25.214000 +00:00', '2022-02-11 15:29:31.049000 +00:00', null, true, true);
INSERT INTO practica.revisions (id_revision, vehicle_id, date_revision, kilometers, revision_cost, currency_id, created_at, updated_at, updated_by, is_available, is_enabled) VALUES ('0007db72-3211-11ed-9b71-708bcd076c78', '9f79f0ca-320f-11ed-aa83-708bcd076c78', '2022-03-11 15:30:05.254000 +00:00', 6875.56000, 335.45000, 'f56085a8-320f-11ed-8831-708bcd076c78', '2022-03-11 15:30:40.274000 +00:00', '2022-03-11 15:30:44.576000 +00:00', null, true, true);
INSERT INTO practica.revisions (id_revision, vehicle_id, date_revision, kilometers, revision_cost, currency_id, created_at, updated_at, updated_by, is_available, is_enabled) VALUES ('00093b2a-3211-11ed-9b72-708bcd076c78', '9f79f0ca-320f-11ed-aa83-708bcd076c78', '2022-07-11 15:31:11.599000 +00:00', 10045.95000, 568.45000, 'f5628272-320f-11ed-8833-708bcd076c78', '2022-07-11 15:31:57.947000 +00:00', '2022-07-11 15:32:04.310000 +00:00', null, true, true);
INSERT INTO practica.revisions (id_revision, vehicle_id, date_revision, kilometers, revision_cost, currency_id, created_at, updated_at, updated_by, is_available, is_enabled) VALUES ('000a73aa-3211-11ed-9b73-708bcd076c78', '9f79f0ca-320f-11ed-aa83-708bcd076c78', '2022-08-14 15:32:27.005000 +00:00', 18475.00000, 432.84000, 'f56085a8-320f-11ed-8831-708bcd076c78', '2022-08-08 15:33:05.882000 +00:00', '2022-08-08 15:33:14.635000 +00:00', null, true, true);
INSERT INTO practica.revisions (id_revision, vehicle_id, date_revision, kilometers, revision_cost, currency_id, created_at, updated_at, updated_by, is_available, is_enabled) VALUES ('37fdb3e4-3211-11ed-9b74-708bcd076c78', '9f7b9e52-320f-11ed-aa84-708bcd076c78', '2021-09-11 15:34:13.938000 +00:00', 35004.24000, 534.21000, 'f56085a8-320f-11ed-8831-708bcd076c78', '2021-09-11 15:33:51.084000 +00:00', '2021-09-11 15:33:57.231000 +00:00', null, true, true);
INSERT INTO practica.revisions (id_revision, vehicle_id, date_revision, kilometers, revision_cost, currency_id, created_at, updated_at, updated_by, is_available, is_enabled) VALUES ('de0a3fa0-3211-11ed-9b75-708bcd076c78', '9f7b9e52-320f-11ed-aa84-708bcd076c78', '2021-12-11 15:35:23.722000 +00:00', 45042.20000, 657.54000, 'f56085a8-320f-11ed-8831-708bcd076c78', '2021-12-11 15:36:00.548000 +00:00', '2021-12-11 15:36:14.086000 +00:00', null, true, true);
INSERT INTO practica.revisions (id_revision, vehicle_id, date_revision, kilometers, revision_cost, currency_id, created_at, updated_at, updated_by, is_available, is_enabled) VALUES ('de0b783e-3211-11ed-9b76-708bcd076c78', '9f7b9e52-320f-11ed-aa84-708bcd076c78', '2022-03-11 15:37:04.042000 +00:00', 55000.00000, 635.45000, 'f56085a8-320f-11ed-8831-708bcd076c78', '2022-03-11 15:37:42.416000 +00:00', '2022-03-11 15:37:47.483000 +00:00', null, true, true);
INSERT INTO practica.revisions (id_revision, vehicle_id, date_revision, kilometers, revision_cost, currency_id, created_at, updated_at, updated_by, is_available, is_enabled) VALUES ('de0c89a4-3211-11ed-9b77-708bcd076c78', '9f7b9e52-320f-11ed-aa84-708bcd076c78', '2022-06-11 15:38:07.643000 +00:00', 58000.00000, 348.65000, 'f56085a8-320f-11ed-8831-708bcd076c78', '2022-06-11 15:38:36.183000 +00:00', '2022-06-11 15:38:40.363000 +00:00', null, true, true);
INSERT INTO practica.revisions (id_revision, vehicle_id, date_revision, kilometers, revision_cost, currency_id, created_at, updated_at, updated_by, is_available, is_enabled) VALUES ('de0dc27e-3211-11ed-9b78-708bcd076c78', '9f7b9e52-320f-11ed-aa84-708bcd076c78', '2022-09-09 15:39:00.637000 +00:00', 65000.00000, 556.25000, 'f56085a8-320f-11ed-8831-708bcd076c78', '2022-09-09 15:39:24.725000 +00:00', '2022-09-09 15:39:31.464000 +00:00', null, true, true);


/*

Consulta
*/
/*
Aparte del script, habrá que entregar una consulta SQL para sacar el siguiente listado de
coches activos que hay en KeepCoding:
- Nombre modelo, marca y grupo de coches (los nombre de todos)
- Fecha de compra
- Matricula
- Nombre del color del coche

- Total kilómetros

- Nombre empresa que esta asegurado el coche
- Numero de póliza

 */

select car_km.model_name as "Modelo", car_km.brand_name as "Marca", car_km.group_name as "Grupo empresarial", car_km.adquisition_date as "Fecha de compra",
       car_km.vehicle_registration as "Matricula", car_km.color_name as "Color", car_km.kilometers as "Total de Kilometros", insurance_car.insurance_carrier_name as "Aseguradora", insurance_car.policy_number as "Número de póliza" from
(select car_details.model_name, car_details.brand_name, car_details.group_name, car_details.id_vehicle, car_details.adquisition_date, car_details.vehicle_registration, car_details.color_name, car_details.vehicle_policy_id, kilometers.kilometers from
(select veh.model_name, veh.brand_name, veh.group_name, veh.id_vehicle, veh.adquisition_date, veh.vehicle_registration, veh.color_name, veh.vehicle_policy_id
from (select * from
(select practica.vehicle_model.model_name, cgb.brand_name, cgb.group_name, practica.vehicle_model.id_vehicle_model from
(select * from practica.vehicle_commercial_group inner join practica.vehicle_brand
    on vehicle_brand.vehicle_commercial_group_id = vehicle_commercial_group.id_vehicle_commercial_group) as cgb inner join practica.vehicle_model
        on cgb.id_vehicle_brand = vehicle_model.vehicle_brand_id) as cbm inner join practica.vehicle
            on cbm.id_vehicle_model = practica.vehicle.vehicle_model_id where is_available is not false) as veh) as car_details
inner join
(select distinct on (practica.revisions.vehicle_id) practica.revisions.vehicle_id, revisions.kilometers
from practica.revisions inner join practica.currency c on c.id_currency = revisions.currency_id
order by practica.revisions.vehicle_id, kilometers desc ) as kilometers
on car_details.id_vehicle = kilometers.vehicle_id) as car_km

inner join
(select id_vehicle_policy, policy_number, insurance_carrier_name from
(select * from practica.vehicle_policy inner join practica.insurance_carrier
    on vehicle_policy.insurance_carrier_id = insurance_carrier.id_insurance_carrier where practica.vehicle_policy.is_available is not false) as insurance) as insurance_car
on car_km.vehicle_policy_id = insurance_car.id_vehicle_policy;