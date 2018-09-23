<?php
// COMP3311 18s1 Assignment 2
// Functions for assignment Tasks A-E
// Written by Kevin Huang (z3461590), May 2018

// assumes that defs.php has already been included


// Task A: get members of an academic object group

// E.g. list($type,$codes) = membersOf($db, 111899)
// Inputs:
//  $db = open database handle
//  $groupID = acad_object_group.id value
// Outputs:
//  array(GroupType,array(Codes...))
//  GroupType = "subject"|"stream"|"program"
//  Codes = acad object codes in alphabetical order
//  e.g. array("subject",array("COMP2041","COMP2911"))


// function to add query to an array
function query_to_array($query,$db, $group) {
	$res = dbQuery($db, $query);
	while ($tup = dbNext($res)) {
		array_push($group, $tup[0]);
	}
	return $group;
}

// this function takes any pattern encountered and adds to the group
function pattern_to_group($db, $pattern, $gtype, $group) {
	
	// have to append an s
	$gtypes = $gtype."s";

	// SPECIAL PATTERNS just return the pattern itself
	if (preg_match("/^FREE|^GENG|^GEN#|^####|^all|^ALL/", $pattern)) {
		array_push($group, $pattern);
	

	// code followed by faculty 
	// TODO: PROBLEM CAN"T TEST ANYTHING HERE	
	} elseif (preg_match("/(.*?)\/F=(.*?)$/", $pattern, $matches)) {
		$code = $matches[0];
		$faculty = $matches[1];
			if (preg_match("/^FREE|^GENG|^GEN#|^####|^all|^ALL/", $pattern)) {
				array_push($group, $pattern);
			} else {
				$qry = "select code from %ss sub, orgunits o where sub.code ~ %s
				        and o.id = sub.offeredby and o.unswid = %s";
				$query = mkSQL($qry, $gtype, $code, $faculty);
				$group = query_to_array($query,$db,$group);
			}		
	// !pattern everything except this pattern (needs a new query)	
	} elseif (preg_match("/^!/", $pattern)) {
		$qry = "select code from $gtypes sub where sub.code !~ %s";
		$query = mkSQL($qry, $pattern);
		$group = query_to_array($query,$db,$group);
	// every other case
	} else {
		$qry = "select code from $gtypes sub where sub.code ~ %s";
		$query = mkSQL($qry, $pattern);
		$group = query_to_array($query,$db,$group);
	}
	return $group;
}

function membersOf($db,$groupID)
{
	$group = array();
	// This array will contain all the codes

	// problems with PARENT (subgroup), not sure if i should encase everything in a for loop
	$q = "select * from acad_object_groups where id = %d or parent = %d";
	//db one tuple returns 
	foreach(dbAllTuples($db, mkSQL($q, $groupID, $groupID)) as $tuple) {
		$gtype = $tuple["gtype"];
		$acad_id = $tuple["id"];

		// Case when enumerated occurs
		if ($tuple["gdefby"] == "enumerated") {

			$qry = "select code from %ss sub, %s_group_members gm where gm.ao_group = %d and sub.id = gm.%s order by code";
			$res = dbQuery($db, str_replace("'", "" ,mkSQL($qry, $gtype, $gtype, $acad_id, $gtype)));
			// push results into array
			while ($tup = dbNext($res)) {
				array_push($group, $tup[0]);
			}
		} elseif ($tuple["gdefby"] == "pattern") {

			$patterns = $tuple["definition"];

			// DEALS WITH  ZEIT460[2-5],{ZEIT4500;ZEIT4501},{ZEIT4600;ZEIT4601}
			//Replace ; with , and Replace {} with nothing (treat it all as its own patterns)
			$patterns = str_replace(";", ",", $patterns);
			$patterns = str_replace(array('{','}'), "", $patterns);

			$array_of_patterns = explode(",", $patterns);
			$acad_id = $tuple["id"];

			//CYcle through every pattern
			foreach ($array_of_patterns as $pattern) {
				$group = pattern_to_group($db, $pattern, $gtype, $group);
			}
		} elseif ($tuple["gdefby"] == "query") {
			
			// remove id,
			$query = str_replace("id", "distinct ", $tuple["definition"]);
			$query = str_replace(",", "", $query);
			$group = query_to_array($query, $db, $group);
		}


	}
	$group = array_unique($group);
	sort($group);
	return array($grp["gtype"], $group); 
}



function pattern_to_regex ($pattern) {
	
	// contains a hashtag
	if (preg_match("/^FREE|^####$|^all$|^ALL$/", $pattern)) {
		return "^((?!GEN).)*?";
	} elseif (preg_match("/^GENG|^GEN#/", $pattern)) {
		return "^GEN";
	} elseif (preg_match("/^!(.*)/",$pattern, $matches)) {
		$match = $matches[0];
		$match = tr_replace(array("#", "x"), ".", $match);
		return "^((?!$match).)*?";
	}
	return str_replace(array("#", "x"), ".", $pattern);
}

// returns true/false
function check_faculty($pattern) {
	
	if (preg_match("/\/F=/", $pattern)) {
		return true;
	}
	return false;
}

function process_nonfaculty($pattern, $gtype) {
	$query =  "select code from {$gtype}s where code ~ %s";
	
	return mkSQL($query, pattern_to_regex($pattern));	
}

function process_faculty($pattern, $gtype) {
	
	preg_match("/(.*)?\/F=(.*)/", $pattern, $matches);
	$code = $matches[1];
	$faculty = $matches[2];

	$query = "select code from {$gtype}s g, orgunits o 
			  where g.offeredby = o.id
			  and o.unswid = %s
			  and code ~ %s";


	return mkSQL($query, $faculty, pattern_to_regex($code));   
} 


// Task B: check if given object is in a group

// E.g. if (inGroup($db, "COMP3311", 111938)) ...
// Inputs:
//  $db = open database handle
//  $code = code for acad object (program,stream,subject)
//  $groupID = acad_object_group.id value
// Outputs:
//  true/false

function inGroup($db, $code, $groupID)
{
	
	// check gdefby for groupID (pattern, enumerated or query)
	$query = "select id, gtype, gdefby, definition from acad_object_groups where id = $groupID 
			  or parent = $groupID";

	$r = dbQuery($db, $query);

	while($tuple = dbNext($r)){
		if ($tuple["gdefby"] == "pattern") {
			
			$array_of_patterns = explode(",", $tuple["definition"]);	
			foreach ($array_of_patterns as $pattern) {
				
				if (check_faculty($pattern)) {
					$code_query = process_faculty($pattern, $tuple['gtype']);
				} else {
					$code_query = process_nonfaculty($pattern, $tuple['gtype']);	
				}
				$res = dbQuery($db, $code_query);
				while ($tup = dbNext($res)) {
					if ($tup["code"] == $code) {
						return true;
					}
				} 
			} 
		} elseif ($tuple["gdefby"] == "enumerated") { 
			$gtype = $tuple["gtype"];
			
			$code_query ="select code from {$gtype}s g, {$gtype}_group_members gm
					where g.id = gm.{$gtype}
					and gm.ao_group = %d";

			$res = dbQuery($db, mkSQL($code_query,$tuple["id"]));
			while ($tup = dbNext($res)) {
				if ($tup["code"] == $code) {
						return true;
				}
			}
		} elseif ($tuple["gdefby"] == "query") {
			$res = dbQuery($db, $tuple["definition"]);
			while ($tup = dbNext($res)) {
				if ($tup["code"] == $code) {
					return true;
				}
			}
		}	


	}

	return false;
}

function outside_home_faculty($db, $code, $enrolment) {

	$home_faculties = array();

	// faculty of the code
	$q = "select o.id from subjects g, orgunits o 
		  where g.offeredby = o.id
		  and g.code = %s";

	$orgunit_id_subject = dbOneValue($db, mkSQL($q, $code));
	$parent_id_subject = parent_faculty($db, $orgunit_id_subject);


	// check faculty of program
	$program = $enrolment[0];

	$q = "select o.id from programs p, orgunits o 
		  where p.offeredby = o.id
		  and p.id = %s";
	$orgunit_id_program = dbOneValue($db, mkSQL($q, $program));
	$parent_id_program = parent_faculty($db, $orgunit_id_program);
	array_push($home_faculties, $parent_id_program);

	// check faculty of streams

	foreach ($enrolment[1] as $stream) {
		$q = "select o.id from streams s, orgunits o 
		  	  where s.offeredby = o.id
		      and s.id = %s";
		$orgunit_id_stream = dbOneValue($db, mkSQL($q, $stream));
		$parent_id_stream = parent_faculty($db, $orgunit_id_stream);
		array_push($home_faculties, $parent_id_stream);
	} 

	return !in_array($parent_id_subject, $home_faculties);

}

// return id of parent faculty 
function parent_faculty($db, $id) {

	// first get the utype
	$q = "select o.id from orgunits o, orgunit_types ot 
		  where o.id = $id
		  and o.utype = ot.id
		  and ot.name = 'Faculty';";

	$utype = dbOneValue($db, $q);
	if (!empty($utype)) { 
		return $id;
	} else {
		$q = "select owner from orgunit_groups where member = $id";
		$owner = dbOneValue($db, $q);
		return parent_faculty($db, $owner);
	}

}








// Task C: can a subject be used to satisfy a rule

// E.g. if (canSatisfy($db, "COMP3311", 2449, $enr)) ...
// Inputs:
//  $db = open database handle
//  $code = code for acad object (program,stream,subject)
//  $ruleID = rules.id value
//  $enr = array(ProgramID,array(StreamIDs...))
// Outputs:

function canSatisfy($db, $code, $ruleID, $enrolment)
{
	$query = "select * from rules where id = $ruleID";
	$tuples = dbOneTuple($db, $query);

	// bunch of rule stuff (duno if i need)
	$type = $tuples["type"];
	// A bunch of cases where we return false
	// ao_group is null
	$q = "select ao_group from rules where id = %s";
	$ao_group = dbOneValue($db, mkSQL($q, $ruleID));
	if(empty($ao_group)) return false;

	// if the associated group is null?

	// academic object isn't the same type as the obejcts in the group
	$q = "select gtype from acad_object_groups where id = %s";
	$gtype = dbOneValue($db, mkSQL($q, $ao_group));

	// check if our code is in the table?
	// if the types are LR, MR, WM, IR we don't worry about these as it doesnt
	// work for only one subject
	if (in_array($type, array("LR", "MR", "WM", "IR"))) return false;


	// ALL THIS STUFF ABOVE IS BASICALLY CHECKING FOR False cases we dont need to owrry about
	// check the rule type (we asume that gtype is what we are dealing with)
	$q = "select gtype, gdefby, definition from acad_object_groups where id = %s";
	$tuples = dbOneTuple($db, mkSQL($q, $ao_group));

	if ($type == "GE") {		
		return outside_home_faculty($db, $code, $enrolment);
	} else {

		return inGroup($db, $code, $ao_group);
	}
	return false;


}


// Task D: determine student progress through a degree

// E.g. $vtrans = progress($db, 3012345, "05s1");
// Inputs:
//  $db = open database handle
//  $stuID = People.unswid value (i.e. unsw student id)
//  $semester = code for semester (e.g. "09s2")
// Outputs:
//  Virtual transcript array (see spec for details)




// Returns an array of all rules tuples in your program and stream for that 
// current semester (defined by peid).
function all_program_rules($db, $peid, $program){
	$rules = array();
	$q = "(select * from rules_for_program(%d)) 
	       union 
	      (select * from rules_for_stream(%d))";
	$r = dbQuery($db, mkSQL($q, $program, $peid));
	while($t = dbNext($r)){
		if (in_array($t["rulecode"], array("CC", "PE", "FE", "GE", "LR"))){
			$t["uoc_done"] = 0;
			$rules[] = $t;
		}
	}
	return $rules;
}




function is_gen_ed($db, $code, $peid, $program){

	$enrolment = array($program);
	$streams = array();
	$q = "select stream from stream_enrolments where partof = %d";
	$r = dbQuery($db, mkSQL($q, $peid));
	while ($t = dbNext($r)){
		$streams[] = $t["stream"];
	}
	$enrolment[] = $streams;

	return preg_match("/^GEN\d{5}$/", $code) &&
		   outside_home_faculty($db, $code, $enrolment);
}



// Helpers to check if its csrtain rule properties.
function satisfies_min_null($rule){
	return (!is_null($rule["min"]) && is_null($rule["max"]));
}

function satisfies_min_max($rule){
	return (!is_null($rule["min"]) && !is_null($rule["max"])
			&& $rule["uoc_done"] < $rule["max"]);
}
// Can the subject be used to satisfy this rule? If it can than DO SO in another function.
function can_satisfy($db, $code, $rule, $peid, $program){
	if (!inGroup($db, $code, $rule["ao_group"])){
		return false;
	} else {
		// This means it is in the group. So check the requirements haven't been met.
		switch ($rule["rulecode"]) {
    		case "CC":
    			return (satisfies_min_null($rule) || satisfies_min_max($rule));
    			break;
    		case "PE":
    			return (satisfies_min_null($rule) || satisfies_min_max($rule));
        		break;
    		case "FE":
        		return (satisfies_min_null($rule) || satisfies_min_max($rule)) &&
        			   !is_gen_ed($db, $code, $peid, $program);
        		break;
        	case "GE":
        		return (satisfies_min_null($rule) || satisfies_min_max($rule)) &&
        			   is_gen_ed($db, $code, $peid, $program);
        		break;
        	case "LR":
        		break;

		}
	}

	return false;

}


function update_rules($db, $code, $rules, $rule_id){

	$q = "select uoc from subjects where code = %s";
	$uoc = dbOneValue($db, mkSQL($q, $code));
	$new = array();
	foreach ($rules as $rule){
		if ($rule_id == $rule["id"]){
			$rule["uoc_done"] += $uoc;
		}
		$new[] = $rule;
	}
	return $new;
}


// Determine where the rule fits in. Return null if it does not satisfy
// any of the requirements.
function determine_rule($db, $code, $rules, $peid, $program) {
	foreach(array("CC", "PE", "FE", "GE", "LR" ) as $ruletype){
		foreach ($rules as $rule){
			if ($rule["rulecode"] == $ruletype){
			    if (can_satisfy($db, $code, $rule, $peid, $program)){
		           return $rule["id"];
				}
			}
		}
	}

	return null;
}



function progress($db, $stuID, $term)
{


	// Fetch details of "curr" program (may not be $term).
	// This gives the program id of the program being studied in
	// the "curr" semester as well as that curr semester
	
	// Returns peid, programid and semid
	$q = "select * from curr_program(%d, %d)";
	$program = dbOneTuple($db, mkSQL($q, $stuID, $term));


	$q = "select * from transcript(%d,%d)";
	$r = dbQuery($db, mkSQL($q, $stuID, $term));


	// Should add all stream_program/rules to array.
	$rules = all_program_rules($db, $program["peid"], $program["program"]);


	// Create of an to do array. This array will contain
	// Rule id => array(curr_uoc, to_do)

	$results = array();
	while ($t = dbNext($r)) {
		list($code,$term,$title,$mark,$grade,$uoc) = $t;
		if ($title == "Overall WAM"){
			$results[] = array("Overall WAM", $mark, $uoc);
			break;
		} elseif ($title == "No WAM available"){
			$results[] = array("Overall WAM", null, null);
			break;
		} elseif ($grade == "FL" || $grade == "UF"){
			$rule = "Failed. Does not count";
		} else if (is_null($mark) && is_null($grade)){
			$uoc = null;
			$rule = "Incomplete. Does not yet count";
		} else {
			$rule_id = determine_rule($db, $code, $rules, $program["peid"], $program["program"]);
			// Cancellout the rule?
			if (is_null($rule_id)) {
				$rule = "Fits no requirement. Does not count";
			} else {
				$rules = update_rules($db, $code, $rules, $rule_id);

				$q = "select name from rules where id = %d";
				$rule = dbOneValue($db, mkSQL($q, $rule_id));
			}
		}
		$results[] = array($code, $term, $title, $mark, $grade, $uoc, $rule);
	}

	foreach ($rules as $rule){
		if ($rule["uoc_done"] < $rule["min"]){
			$done = $rule["uoc_done"];
			$left = $rule["min"] - $done;
			$q = "select name from rules where id = %d";
			$name = dbOneValue($db, mkSQL($q, $rule["id"]));
			$results[] = array("$done UOC so far; need $left UOC more", $name);
		}
	}
	return $results;
}


// Task E:

// E.g. $advice = advice($db, 3012345, 162, 164)
// Inputs:
//  $db = open database handle
//  $studentID = People.unswid value (i.e. unsw student id)
//  $currTermID = code for current semester (e.g. "09s2")
//  $nextTermID = code for next semester (e.g. "10s1")
// Outputs:
//  Advice array (see spec for details)

function advice($db, $studentID, $currTermID, $nextTermID)
{
	return array(); // stub
}
?>
