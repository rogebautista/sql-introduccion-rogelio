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