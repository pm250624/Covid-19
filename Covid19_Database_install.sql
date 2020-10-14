use template_DB;


CREATE TABLE `covid_process_date` (
  `Process_ID` int(11) NOT NULL,
  `date_begin` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `period` varchar(45) DEFAULT NULL,
  `period_days` int(11) DEFAULT NULL,
  PRIMARY KEY (`Process_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE `covid_processingmessages` (
  `Message` varchar(300) DEFAULT NULL,
  `TimeStamp` timestamp(6) NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE `covid_statedata` (
  `fips` smallint(5) unsigned NOT NULL,
  `state_cd` varchar(2) CHARACTER SET utf8 DEFAULT 'XX',
  `state` varchar(30) CHARACTER SET utf8 DEFAULT NULL,
  `population` int(10) NOT NULL DEFAULT '0',
  `statens` text,
  PRIMARY KEY (`fips`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `coviddata_county` (
  `date` text,
  `county` text,
  `state` text,
  `fips` int(11) DEFAULT NULL,
  `cases` int(11) DEFAULT NULL,
  `deaths` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE `coviddata_state` (
  `date` text,
  `state` text,
  `fips` int(11) DEFAULT NULL,
  `cases` int(11) DEFAULT NULL,
  `deaths` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `coviddata_state_chg` (
  `date_end` date NOT NULL,
  `date_begin` date DEFAULT NULL,
  `period` varchar(45) DEFAULT '1 DAY',
  `period_days` smallint(6) NOT NULL DEFAULT '1',
  `state` varchar(30) NOT NULL,
  `fips` smallint(6) NOT NULL DEFAULT '0',
  `state_cd` varchar(2) DEFAULT 'XX',
  `cases_begin` int(10) unsigned DEFAULT '0',
  `cases_end` int(10) unsigned DEFAULT '0',
  `cases_chg` int(10) DEFAULT '0',
  `cases_avg` int(10) DEFAULT '0',
  `deaths_begin` int(10) unsigned DEFAULT '0',
  `deaths_end` int(10) unsigned DEFAULT '0',
  `deaths_chg` int(10) DEFAULT '0',
  `deaths_avg` int(10) DEFAULT '0',
  `pop` int(10) unsigned DEFAULT '0',
  `casesPer100k` decimal(10,2) DEFAULT '0.00',
  `rate_chg` decimal(10,2) DEFAULT '0.00',
  `flag` bit(1) DEFAULT b'0',
  `section` tinyint(3) DEFAULT '2',
  `max_value` tinyint(3) DEFAULT '2',
  `description` varchar(100) DEFAULT '',
  PRIMARY KEY (`date_end`,`period_days`,`fips`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE `coviddata_state_history` (
  `date_end` date NOT NULL,
  `date_begin` date DEFAULT NULL,
  `period` varchar(45) DEFAULT '1 DAY',
  `period_days` smallint(6) NOT NULL DEFAULT '1',
  `state` varchar(30) NOT NULL,
  `fips` smallint(6) NOT NULL DEFAULT '0',
  `state_cd` varchar(2) DEFAULT 'XX',
  `cases_begin` int(10) unsigned DEFAULT '0',
  `cases_end` int(10) unsigned DEFAULT '0',
  `cases_chg` int(10) DEFAULT '0',
  `cases_avg` int(10) DEFAULT '0',
  `deaths_begin` int(10) unsigned DEFAULT '0',
  `deaths_end` int(10) unsigned DEFAULT '0',
  `deaths_chg` int(10) DEFAULT '0',
  `deaths_avg` int(10) DEFAULT '0',
  `casesPer100k` decimal(10,2) DEFAULT '0.00',
  `rate_chg` decimal(10,2) DEFAULT '0.00',
  `flag` bit(1) DEFAULT b'0',
  `section` tinyint(3) DEFAULT '2',
  `max_value` tinyint(3) DEFAULT '2',
  PRIMARY KEY (`date_end`,`period_days`,`fips`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/* Compare cycles  */
CREATE ALGORITHM=UNDEFINED DEFINER=`root1`@`localhost` SQL SECURITY DEFINER VIEW `coviddata_state_periodbegin_v` AS select `coviddata_state`.`date` AS `date`,`coviddata_state`.`state` AS `state`,`coviddata_state`.`fips` AS `fips`,`coviddata_state`.`cases` AS `cases`,`coviddata_state`.`deaths` AS `deaths` 
from (`coviddata_state` join `covid_process_date` on((`coviddata_state`.`date` = `covid_process_date`.`date_begin`)));

CREATE ALGORITHM=UNDEFINED DEFINER=`root1`@`localhost` SQL SECURITY DEFINER VIEW `coviddata_state_periodend_v` AS select `coviddata_state`.`date` AS `date`,`coviddata_state`.`state` AS `state`,`coviddata_state`.`fips` AS `fips`,`coviddata_state`.`cases` AS `cases`,`coviddata_state`.`deaths` AS `deaths`,`covid_process_date`.`period` AS `period`,`covid_process_date`.`period_days` AS `period_days` 
from (`coviddata_state` join `covid_process_date` on((`coviddata_state`.`date` = `covid_process_date`.`date_end`)));

CREATE ALGORITHM=UNDEFINED DEFINER=`root1`@`localhost` SQL SECURITY DEFINER VIEW `coviddata_state_periodchg_v` AS select `end`.`date` AS `date_end`,`begin`.`date` AS `date_begin`,`end`.`period` AS `period`,`end`.`period_days` AS `period_days`,`end`.`state` AS `state`,`end`.`fips` AS `fips`,`begin`.`cases` AS `cases_begin`,`end`.`cases` AS `cases_end`,(`end`.`cases` - `begin`.`cases`) AS `cases_chg`,cast(((`end`.`cases` - `begin`.`cases`) / `end`.`period_days`) as signed) AS `cases_avg`,`begin`.`deaths` AS `deaths_begin`,`end`.`deaths` AS `deaths_end`,(`end`.`deaths` - `begin`.`deaths`) AS `deaths_chg`,cast(((`end`.`deaths` - `begin`.`deaths`) / `end`.`period_days`) as signed) AS `deaths_avg` 
from (`coviddata_state_periodbegin_v` `begin` join `coviddata_state_periodend_v` `end` on((`begin`.`fips` = `end`.`fips`))) order by (`end`.`cases` - `begin`.`cases`) desc;

/* Bring in state population and calculate infections per 100k */
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `coviddata_state_cases_per_100k_v` AS 
select `covid`.`date_end` AS `date_end`,`covid`.`date_begin` AS `date_begin`,`covid`.`period` AS `period`,`covid`.`period_days` AS `period_days`,`stdata`.`state` AS `state`,`covid`.`fips` AS `fips`,`stdata`.`state_cd` AS `state_cd`,`covid`.`cases_begin` AS `cases_begin`,`covid`.`cases_end` AS `cases_end`,`covid`.`cases_chg` AS `cases_chg`,`covid`.`cases_avg` AS `cases_avg`,`covid`.`deaths_begin` AS `deaths_begin`,`covid`.`deaths_end` AS `deaths_end`,`covid`.`deaths_chg` AS `deaths_chg`,`covid`.`deaths_avg` AS `deaths_avg`,`stdata`.`population` AS `pop`,format((`covid`.`cases_chg` / (`stdata`.`population` / 100000)),0) AS `casesPer100k` 
from (`coviddata_state_periodchg_v` `covid` join `covid_statedata` `stdata` on((`covid`.`fips` = `stdata`.`fips`))) order by (`covid`.`cases_chg` / `stdata`.`population`) desc;

/* Two main views, used in app */
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `coviddata_state_chg_history_v` AS select `chg`.`date_end` AS `date_end`,`chg`.`date_begin` AS `date_begin`,`chg`.`period` AS `period`,`chg`.`period_days` AS `period_days`,`chg`.`state` AS `state`,`chg`.`fips` AS `fips`,`chg`.`state_cd` AS `state_cd`,`chg`.`cases_begin` AS `cases_begin`,`chg`.`cases_end` AS `cases_end`,`chg`.`cases_chg` AS `cases_chg`,`chg`.`cases_avg` AS `cases_avg`,`chg`.`deaths_begin` AS `deaths_begin`,`chg`.`deaths_end` AS `deaths_end`,`chg`.`deaths_chg` AS `deaths_chg`,`chg`.`deaths_avg` AS `deaths_avg`,`chg`.`casesPer100k` AS `casesPer100k`,`chg`.`rate_chg` AS `rate_chg`,`chg`.`flag` AS `flag`,`chg`.`section` AS `section` 
from `coviddata_state_history` `chg` where (`chg`.`period_days` = 7) order by `chg`.`date_end` desc,`chg`.`section`,`chg`.`casesPer100k` desc;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `coviddata_state_chg_v` AS select `chg`.`date_end` AS `date_end`,`chg`.`date_begin` AS `date_begin`,`chg`.`period` AS `period`,`chg`.`period_days` AS `period_days`,`chg`.`state` AS `state`,`chg`.`fips` AS `fips`,`chg`.`state_cd` AS `state_cd`,`chg`.`cases_begin` AS `cases_begin`,`chg`.`cases_end` AS `cases_end`,`chg`.`cases_chg` AS `cases_chg`,`chg`.`cases_avg` AS `cases_avg`,`chg`.`deaths_begin` AS `deaths_begin`,`chg`.`deaths_end` AS `deaths_end`,`chg`.`deaths_chg` AS `deaths_chg`,`chg`.`deaths_avg` AS `deaths_avg`,`chg`.`pop` AS `pop`,`chg`.`casesPer100k` AS `casesPer100k`,`chg`.`rate_chg` AS `rate_chg`,`chg`.`flag` AS `flag`,`chg`.`section` AS `section` 
from `coviddata_state_chg` `chg` where (`chg`.`period_days` = 7) order by `chg`.`section`,`chg`.`casesPer100k` desc;



/* for reviewing cycles */
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `coviddata_state_chg_cycles_v` AS select `coviddata_state_chg`.`date_end` AS `date`,`coviddata_state_chg`.`period_days` AS `period_days`,sum(`coviddata_state_chg`.`cases_end`) AS `totalCases`,sum(`coviddata_state_chg`.`cases_chg`) AS `newCases`,sum(`coviddata_state_chg`.`deaths_end`) AS `totalDeaths`,sum(`coviddata_state_chg`.`deaths_chg`) AS `newDeaths`,format(sum(`coviddata_state_chg`.`pop`),0) AS `population`,count(1) AS `numRecs` 
from `coviddata_state_chg` group by `coviddata_state_chg`.`date_end`,`coviddata_state_chg`.`period_days` order by `coviddata_state_chg`.`date_end` desc,`coviddata_state_chg`.`period_days`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `coviddata_state_cycles_v` AS select `coviddata_state`.`date` AS `date`,sum(`coviddata_state`.`cases`) AS `cases`,sum(`coviddata_state`.`deaths`) AS `deaths`,count(1) AS `NumRecs` 
from `coviddata_state` group by `coviddata_state`.`date` order by `coviddata_state`.`date` desc;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `coviddata_state_history_cycles_v` AS select `coviddata_state_history`.`date_end` AS `date`,`coviddata_state_history`.`period_days` AS `period_days`,sum(`coviddata_state_history`.`cases_end`) AS `totalCases`,sum(`coviddata_state_history`.`cases_chg`) AS `newCases`,sum(`coviddata_state_history`.`deaths_end`) AS `totalDeaths`,sum(`coviddata_state_history`.`deaths_chg`) AS `newDeaths`,count(1) AS `numRecs` 
from `coviddata_state_history` group by `coviddata_state_history`.`date_end`,`coviddata_state_history`.`period_days` order by `coviddata_state_history`.`date_end` desc,`coviddata_state_history`.`period_days`;



/* Load Data for State data (e.g. population, state codes, etc), COVID 19 data (via NY Times) and add a record for the process date table */

Insert into covid_process_date(Process_ID, date_begin, date_end, period, period_days)
VALUES(1, "2020-01-01", "2020-01-02", "1 DAY", 1);




DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Covid_LoadCycle`(inProcessDate DATE, cycle TINYINT)
BEGIN

	set @period_days = cycle;
    set @date_end = inProcessDate;
    set @date_begin = DATE_SUB(@date_end, INTERVAL @period_days DAY);


	update covid_process_date
	set date_begin=@date_begin,
    date_end=@date_end,
    period = concat(convert(@period_days, char), ' Day'),
    period_days = @period_days
    where process_id=1;
    
    delete from coviddata_state_chg where period_days = @period_days;

    Insert into coviddata_state_chg(date_end, date_begin, period, period_days, state, fips, state_cd, cases_begin, cases_end, cases_chg, cases_avg, deaths_begin, deaths_end, deaths_chg, deaths_avg, pop, casesPer100k, section)
	Select date_end, date_begin, period, period_days, state, fips, state_cd, cases_begin, cases_end, cases_chg, cases_avg, deaths_begin, deaths_end, deaths_chg, deaths_avg, pop, casesPer100k, 2 
    from coviddata_state_cases_per_100k_V;
     
    update coviddata_state_chg chg
    set section = 3 
    where chg.fips in (78, 66, 69);

     /* Load USA Totals */

     Insert into coviddata_state_chg(date_end, date_begin, period, period_days, state, fips, state_cd, cases_begin, cases_end, cases_chg, cases_avg, deaths_begin, deaths_end, deaths_chg, deaths_avg, pop, casesPer100k, rate_chg, section)
                         select chg.date_end, chg.date_begin, chg.period, chg.period_days, 'U.S.A.', 0, 'US', sum(cases_begin), sum(cases_end), sum(cases_chg), sum(cases_avg), sum(deaths_begin), sum(deaths_end), sum(deaths_chg), sum(deaths_avg), sum(pop), sum(casesPer100k), sum(rate_chg), 1 as section
     From coviddata_state_chg as chg join covid_process_date pro on chg.date_end = pro.date_end and chg.period_days=pro.period_days 
     group by date_begin, date_end, period, period_days;

     update coviddata_state_chg chg
     join covid_process_date pro on chg.date_end = pro.date_end and chg.period_days=pro.period_days 
     set casesPer100k = format((cases_chg/(pop/100000)), 0)
     where chg.fips=0;

	
     /* Calculate the rate of change for casesPer100k from last period to the current one.  This will tell us if infections are increasing or decreasing */
     Update coviddata_state_chg chg1
     join covid_process_date as pro on chg1.date_end = pro.date_end and chg1.period_days = pro.period_days join 
	 coviddata_state_history as chg2 on chg1.fips = chg2.fips and chg2.date_end = pro.date_begin and chg2.period_days=pro.period_days
     Set chg1.rate_chg = (chg1.casesPer100k - chg2.casesPer100k);


	 delete from coviddata_state_history where period_days = @period_days and date_end=@date_end;
     
	 Insert into coviddata_state_history(date_end, date_begin, period, period_days, state, fips, state_cd, cases_begin, cases_end, cases_chg, cases_avg, deaths_begin, deaths_end, deaths_chg, deaths_avg, casesPer100k, section)
	 Select date_end, date_begin, period, period_days, state, fips, state_cd, cases_begin, cases_end, cases_chg, cases_avg, deaths_begin, deaths_end, deaths_chg, deaths_avg, casesPer100k, section 
     from coviddata_state_chg where period_days = @period_days and date_end=@date_end;



	  /* find out when states hit their highest value */
     update coviddata_state_history chg
     set max_value = 0
     where period_days = @period_days;
     

     Update coviddata_state_history chg 
     join (Select fips, period_days, max(cases_chg) as max_cases From coviddata_state_history group by fips, period_days) max1 on chg.fips = max1.fips and chg.period_days=max1.period_days and chg.cases_chg=max1.max_cases
     set max_Value = 1;


     Update coviddata_state_chg chg 
        join (Select fips, period_days, cases_chg, max(date_end) as last_date, count(*) as numMax From coviddata_state_history where max_value = 1 group by fips, period_days, cases_chg) max1 on chg.fips = max1.fips and chg.period_days=max1.period_days
        set description = concat(chg.period, ' high is ', max1.cases_chg, ' cases, occurring on ', DATE_FORMAT( max1.last_date, "%b %e"), '. ');

END$$
DELIMITER ;



DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Covid_LoadNewCycles`()
BEGIN

set @numRecs = (SELECT count(*) FROM coviddata_state_chg);

/* Set @date_begin to the last process date */
IF @numRecs = 0 THEN
	/* We haven't processed any records yet */
     set @date_begin1 = (select min(date) from coviddata_state);
ELSE
     set @date_begin1 = (select max(date_end) from coviddata_state_history);
END IF;


/* Set @date_end to the last date of available data */
set @date_end1 = (select max(date) from coviddata_state);

set @n = DATEDIFF(@date_end1, @date_begin1); 

set @message = CONCAT('Last day processed = ', @date_begin1, ', number of days to process =', @n);
Insert into covid_processingmessages(message, TimeStamp)
VALUES(@message, now());

WHILE DATEDIFF(@date_end1, @date_begin1) > 0  DO
		/* Set @date_begin to the next process date */
		set @date_begin1 = DATE_ADD(@date_begin1, INTERVAL 1 DAY);
	    Call Covid_LoadCycle(@date_begin1, 1);
		Call Covid_LoadCycle(@date_begin1, 7);
        Call Covid_LoadCycle(@date_begin1, 14);
END WHILE;

END$$
DELIMITER ;


/*  https://stackoverflow.com/questions/10563619/error-code-2013-lost-connection-to-mysql-server-during-query */

CALL Covid_LoadNewCycles();










