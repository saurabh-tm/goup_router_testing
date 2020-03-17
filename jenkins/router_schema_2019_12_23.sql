USE goup_router;

-- addition of new column for soap url
alter table wso2_appilication add column host_url_soap varchar(256);

-- Insertion of etisalat operator
INSERT INTO `operator` (`id`, `name`, `code`) VALUES ('34', 'Etisalat', 'Etisalat');

-- Insertion of etisalat interface
INSERT INTO `interfaces` (`id`, `name`, `mysql_host`, `mysql_port`, `mysql_username`, `mysql_password`, `database_name`, `thirdparty_database_name`) 
VALUES ('35', 'Etisalat', '192.168.1.34', '3306', 'root', 'Ttpl@123', 'etisalat_testing_goup_interface', 'etisalat_testing_goup_interface_thirdparty');

-- Insertion of mapping of operator and interface
INSERT INTO `operator_interface` ( `operator_id`, `interface_id`) VALUES ('34', '35');

-- Insertion of mapping into wso2 table
INSERT INTO `wso2_appilication` (`id`, `name`, `operator`, `country`, `interface_id`, `host`, `version`, `auth_app_key`, `host_url_soap`) VALUES ('25', 'Etisalat-AE', '34', '229', '35', '', 'v1', '883edc1a-0cf4-11e9-9b0d-fe984cc15272', 'http://192.168.1.87:8280/etisalat/v1');



-- Dumping structure for procedure development_goup_router.goup_router_get_operator_interface
DROP PROCEDURE IF EXISTS `goup_router_get_operator_interface`;
DELIMITER //
CREATE PROCEDURE `goup_router_get_operator_interface`(
	IN `in_identifier` varchar(256),
	IN `in_identifier_value` varchar(256)
)
    COMMENT 'This procedure is used to get all details of sim identifier with operator interface.'
BEGIN
	/*
		----------------------------------------------------------------------------------------------------------------
		Description	:  This procedure is used to get all details of sim identifier with operator interface.
		Created On  :  15/06/2018
		Created By	:  Nimisha Mittal
		Modify On   :  02/04/2019
		Changed description: Handle identifier
		----------------------------------------------------------------------------------------------------------------
		Inputs		:   IN in_identifier varchar(256),
							IN in_identifier_value varchar(256)
		Output		:		
		-----------------------------------------------------------------------------------------------------------------
        Modified On	:	23 Dec 2019
        Modified By	:	Saurabh kumar
        Modification    Added one more column host_url_soap in return statement
        -----------------------------------------------------------------------------------------------------------------
	*/
    	-- set the length of group concat
		SET SESSION group_concat_max_len = 1000000;
		set @donor_query_case:=NULL;
		set @donor_query:=NULL;

		set @home_query_case:=NULL;
		set @home_query:=NULL;
		set in_identifier=trim(in_identifier);
        set in_identifier_value=trim(in_identifier_value);
        
		set @temp_unique_identifier:=(select sim_identfier_bin from sim_map where sim_identfier = in_identifier_value);
		set @temp_home_identifiers:=(select sim_identfier_bin from sim_home_identifiers where sim_id=in_identifier_value and name=in_identifier);
		set @temp_donor_identifiers:=(select sim_identfier_bin from sim_donor_identfiers where sim_id=in_identifier_value and name=in_identifier);


		set @temp_sim_id_bin:=(select coalesce(@temp_unique_identifier,@temp_home_identifiers,@temp_donor_identifiers)) ;
    if (@temp_sim_id_bin is null )then 
    select 'Data not available' as msg;
    else
		drop temporary table if exists temp_donor_data;
		drop temporary table if exists temp_home_data;
    
		-- query to create cases
		set @home_query_case:=(
		select 
		group_concat(distinct( concat("max(case when sim_home_identifiers.name='",sim_home_identifiers.name,"'"," then "," sim_home_identifiers.sim_id "," else null end) as `",CONCAT(LCASE(LEFT(sim_home_identifiers.name, 1)), LCASE(SUBSTRING(sim_home_identifiers.name, 2))),"`") ))
		from  
		sim_map
		JOIN wso2_appilication ON sim_map.wso2_appilication_id = wso2_appilication.id
		LEFT JOIN sim_home_identifiers ON sim_map.sim_identfier_bin = sim_home_identifiers.sim_identfier_bin
		JOIN operator ON operator.id = wso2_appilication.operator
		JOIN country ON country.id = wso2_appilication.country
		JOIN interfaces ON interfaces.id = wso2_appilication.interface_id
		where sim_home_identifiers.sim_identfier_bin=@temp_sim_id_bin
		);
		if(@home_query_case is null) then 
		 		 -- query to create cases
				set @donor_query_case:=(
				select 
				group_concat(distinct( concat("max(case when sim_donor_identfiers.name='",sim_donor_identfiers.name,"'"," then "," sim_donor_identfiers.sim_id "," else null end) as `",CONCAT(LCASE(LEFT(sim_donor_identfiers.name, 1)), LCASE(SUBSTRING(sim_donor_identfiers.name, 2))),"`") ))
				from   sim_map
				JOIN wso2_appilication ON sim_map.wso2_appilication_id = wso2_appilication.id
				LEFT JOIN sim_donor_identfiers ON sim_map.sim_identfier_bin = sim_donor_identfiers.sim_identfier_bin
				JOIN operator ON operator.id = wso2_appilication.operator
				JOIN country ON country.id = wso2_appilication.country
				JOIN interfaces ON interfaces.id = wso2_appilication.interface_id
		      where sim_donor_identfiers.sim_identfier_bin=@temp_sim_id_bin
				);		
				
			 	set @donor_query:=(select
					concat(" create temporary table temp_donor_data ","
								select sim_map.id as sim_map_id,
								sim_map.sim_identfier as `sim_identfier`,
								wso2_appilication.host as wso2_appilication_host,
								country.name as `country_name`,
			                    country.code as `country_code`,
								wso2_appilication.country as country_id,
								wso2_appilication.operator as operator_id,
								operator.name as `operator_name`,
                                wso2_appilication.host_url_soap as wso2_appilication_host_soap,",
								@donor_query_case,
								" from   sim_map
								JOIN wso2_appilication ON sim_map.wso2_appilication_id = wso2_appilication.id
								LEFT JOIN sim_donor_identfiers ON sim_map.sim_identfier_bin = sim_donor_identfiers.sim_identfier_bin
								JOIN operator ON operator.id = wso2_appilication.operator
								JOIN country ON country.id = wso2_appilication.country
								JOIN interfaces ON interfaces.id = wso2_appilication.interface_id
								where sim_donor_identfiers.sim_identfier_bin='",@temp_sim_id_bin,"'
								group by sim_map.sim_uid",
								" ;"
								) );
			
            
					prepare stmt1 from @donor_query;
					execute stmt1;
					deallocate prepare stmt1;
					select * from temp_donor_data; 
		else
		 			 set @home_query:=(select
							concat(" create temporary table temp_home_data ","
							select sim_map.id as sim_map_id,
							sim_map.sim_identfier as `sim_identfier`,
							wso2_appilication.host as wso2_appilication_host,
							country.name as `country_name`,
		                    country.code as `country_code`,
							wso2_appilication.country as country_id,
							wso2_appilication.operator as operator_id,
							operator.name as `operator_name`,
                            wso2_appilication.host_url_soap as wso2_appilication_host_soap,",
							@home_query_case,
							"from  sim_map
							JOIN wso2_appilication ON sim_map.wso2_appilication_id = wso2_appilication.id
							LEFT JOIN sim_home_identifiers ON sim_map.sim_identfier_bin = sim_home_identifiers.sim_identfier_bin
							JOIN operator ON operator.id = wso2_appilication.operator
							JOIN country ON country.id = wso2_appilication.country
							JOIN interfaces ON interfaces.id = wso2_appilication.interface_id
						   where sim_home_identifiers.sim_identfier_bin='",@temp_sim_id_bin,"'
							group by sim_map.sim_uid",
							" ;"
							) );
							
							prepare stmt2 from @home_query;
							execute stmt2;
							deallocate prepare stmt2; 
		
						select * from temp_home_data; 
		end if;
        end if;
end//
DELIMITER ;


