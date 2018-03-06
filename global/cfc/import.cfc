<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfcomponent output="false" extends="extQueryCaching">

	<!--- Templates: Get all --->
	<cffunction name="getTemplates" output="true">
		<cfargument name="theactive" type="boolean" required="false" default="false">
		<cfargument name="thestruct" type="struct" required="true" />
		<cfset var qry = "">
		<!--- Query --->
		<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		SELECT imp_temp_id, imp_active, imp_name, imp_description
		FROM #arguments.thestruct.razuna.session.hostdbprefix#import_templates
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		<cfif arguments.theactive>
			AND imp_active = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
		</cfif>
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<!--- Get DETAILED Upload Templates ---------------------------------------------------------------------->
	<cffunction name="gettemplatedetail" output="false">
		<cfargument name="imp_temp_id" type="string" required="true">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- New struct --->
		<cfset var qry = structnew()>
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry.imp">
		SELECT imp_who, imp_active, imp_name, imp_description
		FROM #arguments.thestruct.razuna.session.hostdbprefix#import_templates
		WHERE imp_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.imp_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		</cfquery>
		<!--- Query values --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry.impval">
		SELECT imp_field, imp_map, imp_key
		FROM #arguments.thestruct.razuna.session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.imp_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		ORDER BY imp_key DESC, imp_field
		</cfquery>
		<!--- Query key record --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry.impkey">
		SELECT imp_field, imp_map, imp_key
		FROM #arguments.thestruct.razuna.session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.imp_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND imp_key = <cfqueryparam cfsqltype="CF_SQL_DOUBLE" value="true">
		</cfquery>
		<cfreturn qry />
	</cffunction>

	<!--- Get template value ---------------------------------------------------------------------->
	<cffunction name="gettemplatevalue" output="false">
		<cfargument name="imp_temp_id" type="string" required="true">
		<cfargument name="map" type="string" required="true">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Query values --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="q">
		SELECT imp_field
		FROM #arguments.thestruct.razuna.session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.imp_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND imp_map = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.map#">
		</cfquery>
		<cfreturn q.imp_field />
	</cffunction>


	<!--- Save Upload Templates ---------------------------------------------------------------------->
	<cffunction name="settemplate" output="false" returntype="void">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Param --->
		<cfparam name="arguments.thestruct.imp_active" default="0">
		<!--- Delete all records with this ID in the MAIN DB --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#import_templates
		WHERE imp_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">
		</cfquery>
		<!--- Save to main DB --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#import_templates
		(imp_temp_id, imp_date_create, imp_date_update, imp_who, imp_active, host_id, imp_name, imp_description)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">,
		<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.razuna.session.theuserid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_active#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_name#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_description#">
		)
		</cfquery>
		<!--- Delete all records with this ID in the DB --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">
		</cfquery>
		<!--- Get the name and select fields --->
		<cfset var thefield = "">
		<cfset var theselect = "">
		<cfloop collection="#arguments.thestruct#" item="i">
			<cfif i CONTAINS "field_">
				<!--- Get values --->
				<cfset f = listfirst(i,"_")>
				<cfset fn = listlast(i,"_")>
				<cfset fg = f & "_" & fn>
				<cfset thefield = thefield & "," & fg>
			</cfif>
			<cfif i CONTAINS "select_">
				<!--- Get values --->
				<cfset s = listfirst(i,"_")>
				<cfset sn = listlast(i,"_")>
				<cfset sg = s & "_" & sn>
				<cfset theselect = theselect & "," & sg>
			</cfif>
		</cfloop>
		<!--- loop over list amount and do insert and listgetat --->
		<cfloop from="1" to="#listlen(thefield)#" index="i">
			<cfset fi = listgetat(thefield, listfindnocase(thefield,"field_#i#"))>
			<cfset se = listgetat(theselect, listfindnocase(theselect,"select_#i#"))>
			<cfset fi_value = arguments.thestruct["#fi#"]>
			<cfset se_value = arguments.thestruct["#se#"]>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#import_templates_val
			(imp_temp_id_r, host_id, rec_uuid, imp_field, imp_map<cfif arguments.thestruct.radio_key EQ i>, imp_key</cfif>)
			VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#createuuid()#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#fi_value#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#se_value#">
			<cfif arguments.thestruct.radio_key EQ i>,
				<cfqueryparam cfsqltype="CF_SQL_DOUBLE" value="true">
			</cfif>
			)
			</cfquery>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Remove Templates ---------------------------------------------------------------------->
	<cffunction name="removetemplate" output="false" returntype="void">
		<cfargument name="thestruct" type="struct">
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#import_templates
		WHERE imp_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		</cfquery>
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		</cfquery>
		<cfreturn  />
	</cffunction>

	<!--- Upload ---------------------------------------------------------------------->
	<cffunction name="upload" output="false" returntype="String">
		<cfargument name="thestruct" type="struct">
		<!--- Upload file to the temp folder --->
		<cffile action="upload" destination="#GetTempdirectory()#" nameconflict="overwrite" filefield="#arguments.thestruct.thefieldname#" result="thefile">
		<!--- Grab the extensions and create new name --->
		<cfset var ext = listlast(thefile.serverFile,".")>
		<cfset var thenamenew = arguments.thestruct.tempid & "." & ext>
		<!--- Rename --->
		<cffile action="rename" source="#GetTempdirectory()#/#thefile.serverFile#" destination="#GetTempdirectory()#/#thenamenew#" />
		<!--- Set filename in session --->
		<cfset arguments.thestruct.razuna.session.importfilename = thenamenew>
		<!--- Return --->
		<cfreturn ext />
	</cffunction>

	<!--- Do the Import ---------------------------------------------------------------------->
	<cffunction name="doimport" output="false" returntype="void">
		<cfargument name="thestruct" type="struct">
		<!--- Check if file exists if not show error message --->
		<cfif NOT isdefined("arguments.thestruct.razuna.session.importfilename") OR !FileExists("#GetTempdirectory()#/#arguments.thestruct.razuna.session.importfilename#")>
			<cfinvoke component="defaults" method="trans" transid="file_absent" returnvariable="file_absent" />
			<!--- Feedback --->
			<cfoutput><h2>#file_absent#</h2><br><br></cfoutput>
			<cfflush>
			<cfabort>
		</cfif>
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="start_import" returnvariable="start_import" />
		<cfoutput><strong>#start_import#</strong><br><br></cfoutput>
		<cfflush>
		<!--- CSV and XML --->
		<cfif listlast(arguments.thestruct.razuna.session.importfilename,".") EQ "csv">
			<!--- Read the file --->
			<cffile action="read" file="#GetTempdirectory()#/#arguments.thestruct.razuna.session.importfilename#" charset="utf-8" variable="thefile" />
			<!--- Read CSV --->
			<cfset arguments.thestruct.theimport = csvread(string=thefile,headerline=true)>
		<!--- XLS and XLSX --->
		<cfelse>
			<!--- Read the file --->
			<cftry>
				<cfset var thexls = SpreadsheetRead("#GetTempdirectory()#/#arguments.thestruct.razuna.session.importfilename#")>
				<cfset arguments.thestruct.theimport = SpreadsheetQueryread(spreadsheet=thexls,sheet=0,headerrow=1)>
			<cfcatch>
				<cfinvoke component="defaults" method="trans" transid="excel_no_read" returnvariable="excel_no_read" />
				<cfoutput>#excel_no_read#</cfoutput>
				<cfflush>
				<cfabort>
			</cfcatch>
			</cftry>
		</cfif>
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="file_read" returnvariable="file_read" />
		<cfoutput>#file_read#<br><br></cfoutput>
		<cfflush>
		<!--- Do the import --->
		<cfinvoke method="doimporttables" thestruct="#arguments.thestruct#" />
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="clean_up" returnvariable="clean_up" />
		<cfoutput>#clean_up#<br><br></cfoutput>
		<cfflush>
		<!--- Remove the file --->
		<cffile action="delete" file="#GetTempdirectory()#/#arguments.thestruct.razuna.session.importfilename#" />
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="import_success" returnvariable="import_success" />
		<cfoutput><strong style="color:green;">#import_success#</strong><br><br></cfoutput>
		<cfflush>
		<!--- Flush Cache --->
		<cfset resetcachetokenall(hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!---Import: Loop over tables ---------------------------------------------------------------------->
	<cffunction name="doimporttables" output="false" returntype="void">
		<cfargument name="thestruct" type="struct">
		<!--- Is a header template there --->
		<cfif arguments.thestruct.impp_template EQ "">
			<cfinvoke component="defaults" method="trans" transid="no_template" returnvariable="no_template" />
			<!--- Feedback --->
			<cfoutput>#no_template#<br><br></cfoutput>
			<cfflush>
		<!--- If a template has been chosen --->
		<cfelse>
			<cfinvoke component="defaults" method="trans" transid="applying_template" returnvariable="applying_template" />
			<!--- Feedback --->
			<cfoutput>#applying_template#<br><br></cfoutput>
			<cfflush>
			<!--- get template values --->
			<cfset arguments.thestruct.template = gettemplatedetail(imp_temp_id=arguments.thestruct.impp_template, thestruct=arguments.thestruct)>
		</cfif>
		<!--- Do images --->
		<cfinvoke method="doimportimages" thestruct="#arguments.thestruct#" />
		<!--- Do videos --->
		<cfinvoke method="doimportvideos" thestruct="#arguments.thestruct#" />
		<!--- Do audios --->
		<cfinvoke method="doimportaudios" thestruct="#arguments.thestruct#" />
		<!--- Do docs --->
		<cfinvoke method="doimportdocs" thestruct="#arguments.thestruct#" />
		<!--- Return --->
		<cfreturn  />
	</cffunction>

	<!---Import: Images ---------------------------------------------------------------------->
	<cffunction name="doimportimages" output="false" returntype="void">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var c_theid = "img_id" />
		<cfset var c_thisid = "id" />
		<cfset var c_thefilename = "filename" />
		<cfset var c_thekeywords = "keywords" />
		<cfset var c_thedescription = "description" />
		<cfset var c_thelabels = "labels" />
		<cfset var c_theupcnumber = "upc_number" />
		<!--- Params XMP --->
		<cfset var c_theiptcsubjectcode = "iptcsubjectcode" />
		<cfset var c_thecreator = "creator" />
		<cfset var c_thetitle = "title" />
		<cfset var c_theauthorstitle = "authorstitle" />
		<cfset var c_thedescwriter = "descwriter" />
		<cfset var c_theiptcaddress = "iptcaddress" />
		<cfset var c_thecategory = "category" />
		<cfset var c_thecategorysub = "categorysub" />
		<cfset var c_theurgency = "urgency" />
		<cfset var c_theiptccity = "iptccity" />
		<cfset var c_theiptccountry = "iptccountry" />
		<cfset var c_theiptclocation = "iptclocation" />
		<cfset var c_theiptczip = "iptczip" />
		<cfset var c_theiptcemail = "iptcemail" />
		<cfset var c_theiptcwebsite = "iptcwebsite" />
		<cfset var c_theiptcphone = "iptcphone" />
		<cfset var c_theiptcintelgenre = "iptcintelgenre" />
		<cfset var c_theiptcinstructions = "iptcinstructions" />
		<cfset var c_theiptcsource = "iptcsource" />
		<cfset var c_theiptcusageterms = "iptcusageterms" />
		<cfset var c_thecopystatus = "copystatus" />
		<cfset var c_theiptcjobidentifier = "iptcjobidentifier" />
		<cfset var c_thecopyurl = "copyurl" />
		<cfset var c_theiptcheadline = "iptcheadline" />
		<cfset var c_theiptcdatecreated = "iptcdatecreated" />
		<cfset var c_theiptcimagecity = "iptcimagecity" />
		<cfset var c_theiptcimagestate = "iptcimagestate" />
		<cfset var c_theiptcimagecountry = "iptcimagecountry" />
		<cfset var c_theiptcimagecountrycode = "iptcimagecountrycode" />
		<cfset var c_theiptcscene = "iptcscene" />
		<cfset var c_theiptcstate = "iptcstate" />
		<cfset var c_theiptccredit = "iptccredit" />
		<cfset var c_thecopynotice = "copynotice" />
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="import_images" returnvariable="import_images" />
		<cfoutput><strong>#import_images#</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var c_theid = "img_id">
			<cfelse>
				<cfset var c_theid = "img_filename">
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<cftry>
				<!--- If template --->
				<cfif arguments.thestruct.impp_template NEQ "">
					<cfset c_thisid = arguments.thestruct.template.impkey.imp_field>
				</cfif>

				<cfif NOT isdefined("#c_thisid#") >
					<cfinvoke component="defaults" method="trans" transid="id_missing" returnvariable="id_missing" />
					<cfoutput><strong><font color="##CD5C5C">#id_missing#</font></strong></cfoutput>
					<cfflush>
					<cfabort>
				</cfif>

				<!--- Query for existence of the record --->
				<cftry>
					<cfset var found = "">
					<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="found">
					SELECT img_id, path_to_asset, img_filename AS filenameorg, lucene_key, link_path_url
					FROM #arguments.thestruct.razuna.session.hostdbprefix#images
					WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
					AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
					<cfif arguments.thestruct.expwhat NEQ "all">
						AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
					</cfif>
					</cfquery>
					<cfcatch type="database">
						<h2>Oops... #cfcatch.message#</h2>
						<!--- <cfset cfcatch.custom_message = "Database error in function import.doimportimages">
						<cfset errobj.logerrors(cfcatch,false)/> --->
						<cfabort>
					</cfcatch>
				</cftry>
				<!--- If record is found continue --->
				<cfif found.recordcount NEQ 0>
					<!--- Feedback --->
					<cfinvoke component="defaults" method="trans" transid="importing" returnvariable="importing" />
					<cfoutput>#importing# ID: #evaluate(c_thisid)#<br><br></cfoutput>
					<cfflush>
					<!--- Labels --->
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thelabels = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="labels",thestruct=arguments.thestruct)>
					</cfif>
					<cfif c_thelabels NEQ "">
						<cfset tlabel = evaluate(c_thelabels)>
					<cfelse>
						<cfset tlabel = "">
					</cfif>
					<!--- Import Labels --->
					<cfinvoke method="doimportlabels" labels="#tlabel#" assetid="#found.img_id#" kind="img" thestruct="#arguments.thestruct#" />
					<!--- Import Custom Fields --->
					<cfinvoke method="doimportcustomfields" thestruct="#arguments.thestruct#" assetid="#found.img_id#" thecurrentRow="#currentRow#" />
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thefilename = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="filename",thestruct=arguments.thestruct)>
					</cfif>
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_theupcnumber = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="upc_number",thestruct=arguments.thestruct)>
					</cfif>
					<!--- Images: main table --->
					<cfif isdefined("#c_thefilename#") AND evaluate(c_thefilename) NEQ "">
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							UPDATE #arguments.thestruct.razuna.session.hostdbprefix#images
							SET img_filename = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thefilename)#">
							WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
							AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							<cfif arguments.thestruct.expwhat NEQ "all">
								AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
							</cfif>
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- UPC --->
					<cfif isdefined("#c_theupcnumber#") AND evaluate(c_theupcnumber) NEQ "">
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							UPDATE #arguments.thestruct.razuna.session.hostdbprefix#images
							SET img_upc_number= <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_theupcnumber)#">
							WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
							AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							<cfif arguments.thestruct.expwhat NEQ "all">
								AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
							</cfif>
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Keywords & Descriptions --->
					<!--- Check if record is here --->
					<cfset var khere = "">
					<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="khere">
					SELECT it.img_id_r, i.img_id, it.img_keywords, it.img_description
					FROM #arguments.thestruct.razuna.session.hostdbprefix#images i JOIN #arguments.thestruct.razuna.session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND i.host_id = it.host_id
					WHERE i.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
					AND i.img_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.img_id#">
					</cfquery>
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thekeywords = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="keywords",thestruct=arguments.thestruct)>
						<cfset c_thedescription = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="description",thestruct=arguments.thestruct)>
					</cfif>
					<!--- record not found, so do an insert --->
					<cfif khere.img_id_r EQ "">
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#images_text
							(id_inc,img_id_r,lang_id_r,img_keywords,img_description,host_id)
							VALUES(
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.img_id#">,
								<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="1">,
								<cfif c_thekeywords NEQ "">
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thekeywords)#">,
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
								</cfif>
								<cfif c_thedescription NEQ "">
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thedescription)#">,
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
								</cfif>
								<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							)
							</cfquery>
						</cftransaction>
					<cfelse>
						<!--- If append --->
						<cfif arguments.thestruct.imp_write EQ "add">
							<cfif c_thekeywords NEQ "">
								<cfset tkeywords = khere.img_keywords & " " & evaluate(c_thekeywords)>
							<cfelse>
								<cfset tkeywords = khere.img_keywords>
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = khere.img_description & " " & evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = khere.img_description>
							</cfif>
						<cfelse>
							<cfif c_thekeywords NEQ "">
								<cfset tkeywords = evaluate(c_thekeywords)>
							<cfelse>
								<cfset tkeywords = khere.img_keywords>
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = khere.img_description>
							</cfif>
						</cfif>
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							UPDATE #arguments.thestruct.razuna.session.hostdbprefix#images_text
							SET
							img_keywords = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ltrim(tkeywords)#">,
							img_description = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#ltrim(tdescription)#">
							WHERE img_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.img_id#">
							AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Images: XMP --->
					<!--- Check if record is here --->
					<cfset var xmphere = "">
					<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="xmphere">
					SELECT id_r
					FROM #arguments.thestruct.razuna.session.hostdbprefix#xmp
					WHERE host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
					AND id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.img_id#">
					</cfquery>
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_theiptcsubjectcode = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcsubjectcode",thestruct=arguments.thestruct)>
						<cfset c_thecreator = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="creator",thestruct=arguments.thestruct)>
						<cfset c_thetitle = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="title",thestruct=arguments.thestruct)>
						<cfset c_theauthorstitle = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="authorstitle",thestruct=arguments.thestruct)>
						<cfset c_thedescwriter = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="descwriter",thestruct=arguments.thestruct)>
						<cfset c_theiptcaddress = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcaddress",thestruct=arguments.thestruct)>
						<cfset c_thecategory = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="category",thestruct=arguments.thestruct)>
						<cfset c_thecategorysub = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="categorysub",thestruct=arguments.thestruct)>
						<cfset c_theurgency = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="urgency",thestruct=arguments.thestruct)>
						<cfset c_thedescription = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="description",thestruct=arguments.thestruct)>
						<cfset c_theiptccity = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptccity",thestruct=arguments.thestruct)>
						<cfset c_theiptccountry = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptccountry",thestruct=arguments.thestruct)>
						<cfset c_theiptclocation = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptclocation",thestruct=arguments.thestruct)>
						<cfset c_theiptczip = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptczip",thestruct=arguments.thestruct)>
						<cfset c_theiptcemail = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcemail",thestruct=arguments.thestruct)>
						<cfset c_theiptcwebsite = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcwebsite",thestruct=arguments.thestruct)>
						<cfset c_theiptcphone = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcphone",thestruct=arguments.thestruct)>
						<cfset c_theiptcintelgenre = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcintelgenre",thestruct=arguments.thestruct)>
						<cfset c_theiptcinstructions = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcinstructions",thestruct=arguments.thestruct)>
						<cfset c_theiptcsource = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcsource",thestruct=arguments.thestruct)>
						<cfset c_theiptcusageterms = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcusageterms",thestruct=arguments.thestruct)>
						<cfset c_thecopystatus = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="copystatus",thestruct=arguments.thestruct)>
						<cfset c_theiptcjobidentifier = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcjobidentifier",thestruct=arguments.thestruct)>
						<cfset c_thecopyurl = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="copyurl",thestruct=arguments.thestruct)>
						<cfset c_theiptcheadline = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcheadline",thestruct=arguments.thestruct)>
						<cfset c_theiptcdatecreated = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcdatecreated",thestruct=arguments.thestruct)>
						<cfset c_theiptcimagecity = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcimagecity",thestruct=arguments.thestruct)>
						<cfset c_theiptcimagestate = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcimagestate",thestruct=arguments.thestruct)>
						<cfset c_theiptcimagecountry = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcimagecountry",thestruct=arguments.thestruct)>
						<cfset c_theiptcimagecountrycode = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcimagecountrycode",thestruct=arguments.thestruct)>
						<cfset c_theiptcscene = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcscene",thestruct=arguments.thestruct)>
						<cfset c_theiptcstate = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptcstate",thestruct=arguments.thestruct)>
						<cfset c_theiptccredit = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="iptccredit",thestruct=arguments.thestruct)>
						<cfset c_thecopynotice = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="copynotice",thestruct=arguments.thestruct)>
					</cfif>
					<!--- Write arguments for passing to XMP module --->
					<cfif c_thetitle NEQ "">
						<cfset arguments.thestruct.xmp_document_title = evaluate(c_thetitle)>
					</cfif>
					<cfif c_thecreator NEQ "">
						<cfset arguments.thestruct.xmp_author = evaluate(c_thecreator)>
					</cfif>
					<cfif c_theauthorstitle NEQ "">
						<cfset arguments.thestruct.xmp_author_title = evaluate(c_theauthorstitle)>
					</cfif>
					<cfif c_thedescription NEQ "">
						<cfset arguments.thestruct.xmp_description = evaluate(c_thedescription)>
					</cfif>
					<cfif c_thedescwriter NEQ "">
						<cfset arguments.thestruct.xmp_description_writer = evaluate(c_thedescwriter)>
					</cfif>
					<cfif c_thecopystatus NEQ "">
						<cfset arguments.thestruct.xmp_copyright_status = evaluate(c_thecopystatus)>
					</cfif>
					<cfif c_theiptcinstructions NEQ "">
						<cfset arguments.thestruct.xmp_copyright_notice = evaluate(c_theiptcinstructions)>
					</cfif>
					<cfif c_thecopyurl NEQ "">
						<cfset arguments.thestruct.xmp_copyright_info_url = evaluate(c_thecopyurl)>
					</cfif>
					<cfif c_thecategory NEQ "">
						<cfset arguments.thestruct.xmp_category = evaluate(c_thecategory)>
					</cfif>
					<cfif c_thecategorysub NEQ "">
						<cfset arguments.thestruct.xmp_supplemental_categories = evaluate(c_thecategorysub)>
					</cfif>
					<cfif c_theiptcaddress NEQ "">
						<cfset arguments.thestruct.iptc_contact_address = evaluate(c_theiptcaddress)>
					</cfif>
					<cfif c_theiptccity NEQ "">
						<cfset arguments.thestruct.iptc_contact_city = evaluate(c_theiptccity)>
					</cfif>
					<cfif c_theiptclocation NEQ "">
						<cfset arguments.thestruct.iptc_contact_state_province = evaluate(c_theiptclocation)>
					</cfif>
					<cfif c_theiptczip NEQ "">
						<cfset arguments.thestruct.iptc_contact_postal_code = evaluate(c_theiptczip)>
					</cfif>
					<cfif c_theiptccountry NEQ "">
						<cfset arguments.thestruct.iptc_contact_country = evaluate(c_theiptccountry)>
					</cfif>
					<cfif c_theiptcphone NEQ "">
						<cfset arguments.thestruct.iptc_contact_phones = evaluate(c_theiptcphone)>
					</cfif>
					<cfif c_theiptcemail NEQ "">
						<cfset arguments.thestruct.iptc_contact_emails = evaluate(c_theiptcemail)>
					</cfif>
					<cfif c_theiptcwebsite NEQ "">
						<cfset arguments.thestruct.iptc_contact_websites = evaluate(c_theiptcwebsite)>
					</cfif>
					<cfif c_theiptcheadline NEQ "">
						<cfset arguments.thestruct.iptc_content_headline = evaluate(c_theiptcheadline)>
					</cfif>
					<cfif c_theiptcsubjectcode NEQ "">
						<cfset arguments.thestruct.iptc_content_subject_code = evaluate(c_theiptcsubjectcode)>
					</cfif>
					<cfif c_theiptcdatecreated NEQ "">
						<cfset arguments.thestruct.iptc_date_created = evaluate(c_theiptcdatecreated)>
					</cfif>
					<cfif c_theiptcintelgenre NEQ "">
						<cfset arguments.thestruct.iptc_intellectual_genre = evaluate(c_theiptcintelgenre)>
					</cfif>
					<cfif c_theiptcscene NEQ "">
						<cfset arguments.thestruct.iptc_scene = evaluate(c_theiptcscene)>
					</cfif>
					<cfif c_theiptclocation NEQ "">
						<cfset arguments.thestruct.iptc_image_location = evaluate(c_theiptclocation)>
					</cfif>
					<cfif c_theiptcimagecity NEQ "">
						<cfset arguments.thestruct.iptc_image_city = evaluate(c_theiptcimagecity)>
					</cfif>
					<cfif c_theiptcimagecountrycode NEQ "">
						<cfset arguments.thestruct.iptc_image_country = evaluate(c_theiptcimagecountrycode)>
					</cfif>
					<cfif c_theiptcimagestate NEQ "">
						<cfset arguments.thestruct.iptc_image_state_province = evaluate(c_theiptcimagestate)>
					</cfif>
					<cfif c_theiptcimagecountry NEQ "">
						<cfset arguments.thestruct.iptc_iso_country_code = evaluate(c_theiptcimagecountry)>
					</cfif>
					<cfif c_theiptccredit NEQ "">
						<cfset arguments.thestruct.iptc_status_job_identifier = evaluate(c_theiptccredit)>
					</cfif>
					<cfif c_thecopynotice NEQ "">
						<cfset arguments.thestruct.iptc_status_instruction = evaluate(c_thecopynotice)>
					</cfif>
					<cfif c_thecopystatus NEQ "">
						<cfset arguments.thestruct.iptc_status_provider = evaluate(c_thecopystatus)>
					</cfif>
					<cfif c_theiptcsubjectcode NEQ "">
						<cfset arguments.thestruct.iptc_status_source = evaluate(c_theiptcsubjectcode)>
					</cfif>
					<cfif c_theiptcinstructions NEQ "">
						<cfset arguments.thestruct.iptc_status_rights_usage_terms = evaluate(c_theiptcinstructions)>
					</cfif>
					<cfif c_theurgency NEQ "">
						<cfset arguments.thestruct.xmp_origin_urgency = evaluate(c_theurgency)>
					</cfif>
					<!--- if no record found in xmp table do an insert --->
					<cfif xmphere.recordcount EQ 0>
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#xmp
							(id_r,
							asset_type,
							host_id)
							VALUES(
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#found.img_id#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="img">,
								<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
							)
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Call XMP to write metadata --->
					<cfset arguments.thestruct.file_id = found.img_id>
					<cfset arguments.thestruct.img_keywords = ltrim(tkeywords)>
					<cfset arguments.thestruct.img_desc = ltrim(tdescription)>
					<cfif arguments.thestruct.imp_write EQ "add">
						<cfset arguments.thestruct.batch_replace = false>
					</cfif>
					<cfinvoke component="xmp" method="xmpwritethread" thestruct="#arguments.thestruct#" />
					<!--- Set for indexing --->
					<cftransaction>
						<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
						UPDATE #arguments.thestruct.razuna.session.hostdbprefix#images
						SET is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
						WHERE img_id = <cfqueryparam value="#found.img_id#" cfsqltype="CF_SQL_VARCHAR">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
						</cfquery>
					</cftransaction>
				</cfif>
				<!--- Show if error --->
				<cfcatch type="any">
					<!--- <cfdump var="#arguments.thestruct#">
					<cfdump var="#cfcatch#">
					<cfflush>
					<cfabort> --->
					<!--- Feedback --->
					<cfinvoke component="defaults" method="trans" transid="error_occurred" returnvariable="error_occurred" />
					<cfoutput>
						#error_occurred#:
						<br />
						<span style="font-weight:bold;color:red;">
							#cfcatch.message#
							<br />
							#cfcatch.detail#
						</span>
						<br />
						In other words, the field was most likely not defined in your import file. The rest of the values have still imported successfully, but you might want to add the field to your import file the next time.
						<br><br>
					</cfoutput>
					<!--- <cfset cfcatch.custom_message = "Error in function import.doimportimages">
					<cfset errobj.logerrors(cfcatch,false)/> --->
					<cfflush>
				</cfcatch>
			</cftry>
		</cfloop>
		<!--- Flush Cache --->
		<!--- <cfset resetcachetoken(type="images", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="videos", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="audios", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="files", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid)> --->
		<!--- Return --->
		<cfreturn  />
	</cffunction>

	<!---Import: Videos ---------------------------------------------------------------------->
	<cffunction name="doimportvideos" output="false" returntype="void">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var c_theid = "vid_id" />
		<cfset var c_thisid = "id" />
		<cfset var c_thefilename = "filename" />
		<cfset var c_thekeywords = "keywords" />
		<cfset var c_thedescription = "description" />
		<cfset var c_thelabels = "labels" />
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="import_videos" returnvariable="import_videos" />
		<cfoutput><strong>#import_videos#</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var c_theid = "vid_id">
			<cfelse>
				<cfset var c_theid = "vid_filename">
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfset c_thisid = arguments.thestruct.template.impkey.imp_field>
			</cfif>
			<!--- Query for existence of the record --->
			<cftry>
				<cfset var found = "">
				<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="found">
				SELECT vid_id, path_to_asset, vid_filename AS filenameorg, lucene_key, link_path_url
				FROM #arguments.thestruct.razuna.session.hostdbprefix#videos
				WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
				AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
				<cfif arguments.thestruct.expwhat NEQ "all">
					AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
				</cfif>
				</cfquery>
				<cfcatch type="database">
					<h2>Oops... #cfcatch.message#</h2>
					<!--- <cfset cfcatch.custom_message = "Database error in function import.doimportvideos">
					<cfset errobj.logerrors(cfcatch,false)/> --->
					<cfabort>
				</cfcatch>
			</cftry>
			<!--- If record is found continue --->
			<cfif found.recordcount NEQ 0>
				<cftry>
					<!--- Feedback --->
					<cfinvoke component="defaults" method="trans" transid="importing" returnvariable="importing" />
					<cfoutput>#importing# ID: #evaluate(c_thisid)#<br><br></cfoutput>
					<cfflush>
					<!--- Labels --->
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thelabels = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="labels",thestruct=arguments.thestruct)>
					</cfif>
					<cfif c_thelabels NEQ "">
						<cfset tlabel = evaluate(c_thelabels)>
					<cfelse>
						<cfset tlabel = "">
					</cfif>
					<cfinvoke method="doimportlabels" labels="#tlabel#" assetid="#found.vid_id#" kind="vid" thestruct="#arguments.thestruct#" />
					<!--- Import Custom Fields --->
					<cfinvoke method="doimportcustomfields" thestruct="#arguments.thestruct#" assetid="#found.vid_id#" thecurrentRow="#currentRow#" />
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thefilename = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="filename",thestruct=arguments.thestruct)>
					</cfif>
					<!--- Images: main table --->
					<cfif isdefined("#c_thefilename#") AND evaluate(c_thefilename) NEQ "">
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							UPDATE #arguments.thestruct.razuna.session.hostdbprefix#videos
							SET
							vid_filename = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thefilename)#">,
							is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
							WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
							AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							<cfif arguments.thestruct.expwhat NEQ "all">
								AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
							</cfif>
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Keywords & Descriptions --->
					<!--- Check if record is here --->
					<cfset var khere = "">
					<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="khere">
					SELECT it.vid_id_r, i.vid_id, it.vid_keywords, it.vid_description
					FROM #arguments.thestruct.razuna.session.hostdbprefix#videos i JOIN #arguments.thestruct.razuna.session.hostdbprefix#videos_text it ON i.vid_id = it.vid_id_r AND v.host_id = it.host_id
					WHERE i.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
					AND i.vid_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.vid_id#">
					</cfquery>
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thekeywords = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="keywords",thestruct=arguments.thestruct)>
						<cfset c_thedescription = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="description",thestruct=arguments.thestruct)>
					</cfif>
					<!--- record not found, so do an insert --->
					<cfif khere.vid_id_r EQ "">
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#videos_text
							(id_inc,vid_id_r,lang_id_r,vid_keywords,vid_description,host_id)
							VALUES(
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.vid_id#">,
								<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="1">,
								<cfif c_thekeywords NEQ "">
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thekeywords)#">,
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
								</cfif>
								<cfif c_thedescription NEQ "">
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thedescription)#">,
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
								</cfif>
								<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							)
							</cfquery>
						</cftransaction>
					<cfelse>
						<!--- If append --->
						<cfif arguments.thestruct.imp_write EQ "add">
							<cfif c_thekeywords NEQ "">
								<cfset tkeywords = khere.vid_keywords & " " & evaluate(c_thekeywords)>
							<cfelse>
								<cfset tkeywords = khere.vid_keywords>
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = khere.vid_description & " " & evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = khere.vid_description>
							</cfif>
						<cfelse>
							<cfif c_thekeywords NEQ "">
								<cfset tkeywords = evaluate(c_thekeywords)>
							<cfelse>
								<cfset tkeywords = "">
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = "">
							</cfif>
						</cfif>
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							UPDATE #arguments.thestruct.razuna.session.hostdbprefix#videos_text
							SET
							vid_keywords = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tkeywords#">,
							vid_description = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tdescription#">
							WHERE vid_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.vid_id#">
							AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Show if error --->
					<cfcatch type="any">
						<!--- Feedback --->
						<cfinvoke component="defaults" method="trans" transid="error_occurred" returnvariable="error_occurred" />
						<cfoutput>
							#error_occurred#:
							<br />
							<span style="font-weight:bold;color:red;">
								#cfcatch.message#
								<br />
								#cfcatch.detail#
							</span>
							<br />
							In other words, the field was most likely not defined in your import file. The rest of the values have still imported successfully, but you might want to add the field to your import file the next time.
							<br><br>
						</cfoutput>
						<!--- <cfset cfcatch.custom_message = "Error in function import.doimportimages">
						<cfset errobj.logerrors(cfcatch,false)/> --->
						<cfflush>
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<!--- <cfset resetcachetoken(type="images", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="videos", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="audios", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="files", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid)> --->
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!---Import: Audios ---------------------------------------------------------------------->
	<cffunction name="doimportaudios" output="false" returntype="void">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var c_theid = "aud_id" />
		<cfset var c_thisid = "id" />
		<cfset var c_thefilename = "filename" />
		<cfset var c_thekeywords = "keywords" />
		<cfset var c_thedescription = "description" />
		<cfset var c_thelabels = "labels" />
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="import_audios" returnvariable="import_audios" />
		<cfoutput><strong>#import_audios#</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var c_theid = "aud_id">
			<cfelse>
				<cfset var c_theid = "aud_name">
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfset c_thisid = arguments.thestruct.template.impkey.imp_field>
			</cfif>
			<!--- Query for existence of the record --->
			<cftry>
				<cfset var found = "">
				<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="found">
				SELECT aud_id, path_to_asset, aud_name AS filenameorg, lucene_key, link_path_url
				FROM #arguments.thestruct.razuna.session.hostdbprefix#audios
				WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
				AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
				<cfif arguments.thestruct.expwhat NEQ "all">
					AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
				</cfif>
				</cfquery>
				<cfcatch type="database">
					<h2>Oops... #cfcatch.message#</h2>
					<cfabort>
				</cfcatch>
			</cftry>
			<!--- If record is found continue --->
			<cfif found.recordcount NEQ 0>
				<cftry>
					<!--- Feedback --->
					<cfinvoke component="defaults" method="trans" transid="importing" returnvariable="importing" />
					<cfoutput>#importing# ID: #evaluate(c_thisid)#<br><br></cfoutput>
					<cfflush>
					<!--- Labels --->
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thelabels = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="labels",thestruct=arguments.thestruct)>
					</cfif>
					<cfif c_thelabels NEQ "">
						<cfset tlabel = evaluate(c_thelabels)>
					<cfelse>
						<cfset tlabel = "">
					</cfif>
					<cfinvoke method="doimportlabels" labels="#tlabel#" assetid="#found.aud_id#" kind="aud" thestruct="#arguments.thestruct#" />
					<!--- Import Custom Fields --->
					<cfinvoke method="doimportcustomfields" thestruct="#arguments.thestruct#" assetid="#found.aud_id#" thecurrentRow="#currentRow#" />
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thefilename = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="filename",thestruct=arguments.thestruct)>
					</cfif>
					<!--- Images: main table --->
					<cfif isdefined("#c_thefilename#") AND evaluate(c_thefilename) NEQ "">
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							UPDATE #arguments.thestruct.razuna.session.hostdbprefix#audios
							SET
							aud_name = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thefilename)#">,
							is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
							WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
							AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							<cfif arguments.thestruct.expwhat NEQ "all">
								AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
							</cfif>
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Keywords & Descriptions --->
					<!--- Check if record is here --->
					<cfset var khere = "">
					<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="khere">
					SELECT it.aud_id_r, i.aud_id, it.aud_keywords, it.aud_description
					FROM #arguments.thestruct.razuna.session.hostdbprefix#audios i JOIN #arguments.thestruct.razuna.session.hostdbprefix#audios_text it ON i.aud_id = it.aud_id_r AND i.host_id = it.host_id
					WHERE i.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
					AND i.aud_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.aud_id#">
					</cfquery>
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thekeywords = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="keywords",thestruct=arguments.thestruct)>
						<cfset c_thedescription = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="description",thestruct=arguments.thestruct)>
					</cfif>
					<!--- record not found, so do an insert --->
					<cfif khere.aud_id_r EQ "">
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#audios_text
							(id_inc,aud_id_r,lang_id_r,aud_keywords,aud_description,host_id)
							VALUES(
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.aud_id#">,
								<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="1">,
								<cfif c_thekeywords NEQ "">
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thekeywords)#">,
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
								</cfif>
								<cfif c_thedescription NEQ "">
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thedescription)#">,
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
								</cfif>
								<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							)
							</cfquery>
						</cftransaction>
					<cfelse>
						<!--- If append --->
						<cfif arguments.thestruct.imp_write EQ "add">
							<cfif c_thekeywords NEQ "">
								<cfset tkeywords = khere.aud_keywords & " " & evaluate(c_thekeywords)>
							<cfelse>
								<cfset tkeywords = khere.aud_keywords>
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = khere.aud_description & " " & evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = khere.aud_description>
							</cfif>
						<cfelse>
							<cfif c_thekeywords NEQ "">
								<cfset tkeywords = evaluate(c_thekeywords)>
							<cfelse>
								<cfset tkeywords = "">
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = "">
							</cfif>
						</cfif>
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							UPDATE #arguments.thestruct.razuna.session.hostdbprefix#audios_text
							SET
							aud_keywords = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tkeywords#">,
							aud_description = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tdescription#">
							WHERE aud_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.aud_id#">
							AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Show if error --->
					<cfcatch type="any">
						<!--- Feedback --->
						<cfinvoke component="defaults" method="trans" transid="error_occurred" returnvariable="error_occurred" />
						<cfoutput>
							#error_occurred#:
							<br />
							<span style="font-weight:bold;color:red;">
								#cfcatch.message#
								<br />
								#cfcatch.detail#
							</span>
							<br />
							In other words, the field was most likely not defined in your import file. The rest of the values have still imported successfully, but you might want to add the field to your import file the next time.
							<br><br>
						</cfoutput>
						<!--- <cfset cfcatch.custom_message = "Error in function import.doimportimages">
						<cfset errobj.logerrors(cfcatch,false)/> --->
						<cfflush>
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<!--- <cfset resetcachetoken(type="images", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="videos", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="audios", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="files", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid)> --->
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!---Import: Docs ---------------------------------------------------------------------->
	<cffunction name="doimportdocs" output="false" returntype="void">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var c_theid = "file_id" />
		<cfset var c_thisid = "id" />
		<cfset var c_thefilename = "filename" />
		<cfset var c_thekeywords = "keywords" />
		<cfset var c_thedescription = "description" />
		<cfset var c_thelabels = "labels" />
		<!--- Params XMP --->
		<cfset var c_thepdf_author = "pdf_author" />
		<cfset var c_thepdf_rights = "pdf_rights" />
		<cfset var c_thepdf_authorsposition = "pdf_authorsposition" />
		<cfset var c_thepdf_captionwriter = "pdf_captionwriter" />
		<cfset var c_thepdf_webstatement = "pdf_webstatement" />
		<cfset var c_thepdf_rightsmarked = "pdf_rightsmarked" />
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="import_docs" returnvariable="import_docs" />
		<cfoutput><strong>#import_docs#</strong><br><br></cfoutput>
		<cfflush>
		<!--- If template --->
		<cfif arguments.thestruct.impp_template NEQ "">
			<!--- If the imp_map points to the ID --->
			<cfif arguments.thestruct.template.impkey.imp_map EQ "id">
				<cfset var c_theid = "file_id">
			<cfelse>
				<cfset var c_theid = "file_name">
			</cfif>
		</cfif>
		<!--- Loop --->
		<cfloop query="arguments.thestruct.theimport">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfset c_thisid = arguments.thestruct.template.impkey.imp_field>
			</cfif>
			<!--- Query for existence of the record --->
			<cftry>
				<cfset var found = "">
				<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="found">
				SELECT file_id, path_to_asset, file_name AS filenameorg, lucene_key, link_path_url
				FROM #arguments.thestruct.razuna.session.hostdbprefix#files
				WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
				AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
				<cfif arguments.thestruct.expwhat NEQ "all">
					AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
				</cfif>
				</cfquery>
				<cfcatch type="database">
					<h2>Oops... #cfcatch.message#</h2>
					<cfabort>
				</cfcatch>
			</cftry>
			<!--- If record is found continue --->
			<cfif found.recordcount NEQ 0>
				<cftry>
					<!--- Feedback --->
					<cfinvoke component="defaults" method="trans" transid="importing" returnvariable="importing" />
					<cfoutput>#importing# ID: #evaluate(c_thisid)#<br><br></cfoutput>
					<cfflush>
					<!--- Labels --->
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thelabels = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="labels",thestruct=arguments.thestruct)>
					</cfif>
					<cfif c_thelabels NEQ "">
						<cfset tlabel = evaluate(c_thelabels)>
					<cfelse>
						<cfset tlabel = "">
					</cfif>
					<!--- Import Labels --->
					<cfinvoke method="doimportlabels" labels="#tlabel#" assetid="#found.file_id#" kind="doc" thestruct="#arguments.thestruct#" />
					<!--- Import Custom Fields --->
					<cfinvoke method="doimportcustomfields" thestruct="#arguments.thestruct#" assetid="#found.file_id#" thecurrentRow="#currentRow#" />
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thefilename = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="filename",thestruct=arguments.thestruct)>
					</cfif>
					<!--- Images: main table --->
					<cfif isdefined("#c_thefilename#") AND evaluate(c_thefilename) NEQ "">
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							UPDATE #arguments.thestruct.razuna.session.hostdbprefix#files
							SET
							file_name = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thefilename)#">,
							is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
							WHERE #c_theid# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thisid)#">
							AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							<cfif arguments.thestruct.expwhat NEQ "all">
								AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
							</cfif>
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Keywords & Descriptions --->
					<!--- Check if record is here --->
					<cfset var khere = "">
					<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="khere">
					SELECT it.file_id_r, i.file_id, it.file_keywords, it.file_desc
					FROM #arguments.thestruct.razuna.session.hostdbprefix#files i JOIN #arguments.thestruct.razuna.session.hostdbprefix#files_desc it ON i.file_id = it.file_id_r AND i.host_id = it.host_id
					WHERE i.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
					AND i.file_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">
					</cfquery>
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thekeywords = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="keywords",thestruct=arguments.thestruct)>
						<cfset c_thedescription = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="description",thestruct=arguments.thestruct)>
					</cfif>
					<!--- record not found, so do an insert --->
					<cfif khere.file_id_r EQ "">
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#files_desc
							(id_inc,file_id_r,lang_id_r,file_keywords,file_desc,host_id)
							VALUES(
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">,
								<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="1">,
								<cfif c_thekeywords NEQ "">
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thekeywords)#">,
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
								</cfif>
								<cfif c_thedescription NEQ "">
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(c_thedescription)#">,
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">,
								</cfif>
								<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							)
							</cfquery>
						</cftransaction>
					<cfelse>
						<!--- If append --->
						<cfif arguments.thestruct.imp_write EQ "add">
							<cfif c_thekeywords NEQ "">
								<cfset tkeywords = khere.file_keywords & " " & evaluate(c_thekeywords)>
							<cfelse>
								<cfset tkeywords = khere.file_keywords>
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = khere.file_desc & " " & evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = khere.file_desc>
							</cfif>
						<cfelse>
							<cfif c_thekeywords NEQ "">
								<cfset tkeywords = evaluate(c_thekeywords)>
							<cfelse>
								<cfset tkeywords = "">
							</cfif>
							<cfif c_thedescription NEQ "">
								<cfset tdescription = evaluate(c_thedescription)>
							<cfelse>
								<cfset tdescription = "">
							</cfif>
						</cfif>
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							UPDATE #arguments.thestruct.razuna.session.hostdbprefix#files_desc
							SET
							file_keywords = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tkeywords#">,
							file_desc = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tdescription#">
							WHERE file_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">
							AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Files: XMP --->
					<!--- Check if record is here --->
					<cfset var xmphere = "">
					<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="xmphere">
					SELECT it.asset_id_r, i.file_id, it.author, it.rights, it.authorsposition, it.captionwriter, it.webstatement, it.rightsmarked
					FROM #arguments.thestruct.razuna.session.hostdbprefix#files i JOIN #arguments.thestruct.razuna.session.hostdbprefix#files_xmp it ON i.file_id = it.asset_id_r
					WHERE i.host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
					AND i.file_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">
					</cfquery>
					<!--- If template --->
					<cfif arguments.thestruct.impp_template NEQ "">
						<cfset c_thepdf_author = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="pdf_author",thestruct=arguments.thestruct)>
						<cfset c_thepdf_rights = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="pdf_rights",thestruct=arguments.thestruct)>
						<cfset c_thepdf_authorsposition = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="pdf_authorsposition",thestruct=arguments.thestruct)>
						<cfset c_thepdf_captionwriter = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="pdf_captionwriter",thestruct=arguments.thestruct)>
						<cfset c_thepdf_webstatement = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="pdf_webstatement",thestruct=arguments.thestruct)>
						<cfset c_thepdf_rightsmarked = gettemplatevalue(imp_temp_id=arguments.thestruct.impp_template,map="pdf_rightsmarked",thestruct=arguments.thestruct)>
					</cfif>
					<!--- record not found, so do an insert --->
					<cfif xmphere.asset_id_r EQ "">
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#files_xmp
							(author, rights, authorsposition, captionwriter, webstatement, rightsmarked, asset_id_r, host_id)
							VALUES(
								<cfif c_thepdf_author NEQ "">
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_author)#">,
								<cfelse>
									<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
								</cfif>
								<cfif c_thepdf_rights NEQ "">
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_rights)#">,
								<cfelse>
									<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
								</cfif>
								<cfif c_thepdf_authorsposition NEQ "">
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_authorsposition)#">,
								<cfelse>
									<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
								</cfif>
						  	  	<cfif c_thepdf_captionwriter NEQ "">
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_captionwriter)#">,
								<cfelse>
									<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
								</cfif>
						  	  	<cfif c_thepdf_webstatement NEQ "">
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_webstatement)#">,
								<cfelse>
									<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
								</cfif>
						  	  	<cfif c_thepdf_rightsmarked NEQ "">
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(c_thepdf_rightsmarked)#">,
								<cfelse>
									<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
								</cfif>
						  	  	<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">,
						  	  	<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
						  	)
							</cfquery>
						</cftransaction>
					<cfelse>
						<!--- If append --->
						<cfif arguments.thestruct.imp_write EQ "add">
							<cfif c_thepdf_author NEQ "">
								<cfset tpdf_author = xmphere.author & " " & evaluate(c_thepdf_author)>
							<cfelse>
								<cfset tpdf_author = xmphere.author>
							</cfif>
							<cfif c_thepdf_rights NEQ "">
								<cfset tpdf_rights = xmphere.rights & " " & evaluate(c_thepdf_rights)>
							<cfelse>
								<cfset tpdf_rights = xmphere.rights>
							</cfif>
							<cfif c_thepdf_authorsposition NEQ "">
								<cfset tpdf_authorsposition = xmphere.authorsposition & " " & evaluate(c_thepdf_authorsposition)>
							<cfelse>
								<cfset tpdf_authorsposition = xmphere.authorsposition>
							</cfif>
							<cfif c_thepdf_captionwriter NEQ "">
								<cfset tpdf_captionwriter = xmphere.captionwriter & " " & evaluate(c_thepdf_captionwriter)>
							<cfelse>
								<cfset tpdf_captionwriter = xmphere.captionwriter>
							</cfif>
							<cfif c_thepdf_webstatement NEQ "">
								<cfset tpdf_webstatement = xmphere.webstatement & " " & evaluate(c_thepdf_webstatement)>
							<cfelse>
								<cfset tpdf_webstatement = xmphere.webstatement>
							</cfif>
							<cfif c_thepdf_rightsmarked NEQ "">
								<cfset tpdf_rightsmarked = xmphere.rightsmarked & " " & evaluate(c_thepdf_rightsmarked)>
							<cfelse>
								<cfset tpdf_rightsmarked = xmphere.rightsmarked>
							</cfif>
						<cfelse>
							<cfif c_thepdf_author NEQ "">
								<cfset tpdf_author = evaluate(c_thepdf_author)>
							<cfelse>
								<cfset tpdf_author = "">
							</cfif>
							<cfif c_thepdf_rights NEQ "">
								<cfset tpdf_rights = evaluate(c_thepdf_rights)>
							<cfelse>
								<cfset tpdf_rights = "">
							</cfif>
							<cfif c_thepdf_authorsposition NEQ "">
								<cfset tpdf_authorsposition = evaluate(c_thepdf_authorsposition)>
							<cfelse>
								<cfset tpdf_authorsposition = "">
							</cfif>
							<cfif c_thepdf_captionwriter NEQ "">
								<cfset tpdf_captionwriter = evaluate(c_thepdf_captionwriter)>
							<cfelse>
								<cfset tpdf_captionwriter = "">
							</cfif>
							<cfif c_thepdf_webstatement NEQ "">
								<cfset tpdf_webstatement = evaluate(c_thepdf_webstatement)>
							<cfelse>
								<cfset tpdf_webstatement = "">
							</cfif>
							<cfif c_thepdf_rightsmarked NEQ "">
								<cfset tpdf_rightsmarked = evaluate(c_thepdf_rightsmarked)>
							<cfelse>
								<cfset tpdf_rightsmarked = "">
							</cfif>
						</cfif>
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							UPDATE #arguments.thestruct.razuna.session.hostdbprefix#files_xmp
							SET
							author = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_author#">,
		  				  	rights = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_rights#">,
						  	authorsposition = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_authorsposition#">,
						  	captionwriter = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_captionwriter#">,
						  	webstatement = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_webstatement#">,
						  	rightsmarked = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#tpdf_rightsmarked#">
							WHERE asset_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#found.file_id#">
							AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Show if error --->
					<cfcatch type="any">
						<!--- Feedback --->
						<cfinvoke component="defaults" method="trans" transid="error_occurred" returnvariable="error_occurred" />
						<cfoutput>
							#error_occurred#:
							<br />
							<span style="font-weight:bold;color:red;">
								#cfcatch.message#
								<br />
								#cfcatch.detail#
							</span>
							<br />
							In other words, the field was most likely not defined in your import file. The rest of the values have still imported successfully, but you might want to add the field to your import file the next time.
							<br><br>
						</cfoutput>
						<!--- <cfset cfcatch.custom_message = "Error in function import.doimportimages">
						<cfset errobj.logerrors(cfcatch,false)/> --->
						<cfflush>
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<!--- <cfset resetcachetoken(type="images", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="videos", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="audios", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="files", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid)>
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid)> --->
		<!--- Return --->
		<cfreturn  />
	</cffunction>

	<!---Import: Labels ---------------------------------------------------------------------->
	<cffunction name="doimportlabels" output="false" returntype="void">
		<cfargument name="labels" type="string">
		<cfargument name="assetid" type="string">
		<cfargument name="kind" type="string">
		<cfargument name="thestruct" type="struct">
		<!--- Remove all labels for this record --->
		<cfif arguments.thestruct.imp_write NEQ "add">
			<cftransaction>
				<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
				DELETE FROM ct_labels
				WHERE ct_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND ct_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.kind#">
				</cfquery>
			</cftransaction>
		</cfif>
		<!--- Label is usually a list, thus loop it --->
		<cfloop list="#arguments.labels#" delimiters="," index="i">
			<!--- Check if label is in the label db --->
			<cfset var labhere = "">
			<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="labhere">
			SELECT label_id
			FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
			WHERE label_path = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			<!--- Make sure that records exists --->
			AND (
				EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#audios where aud_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#">)
				OR EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#images where img_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#">)
				OR EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#videos where vid_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#">)
				OR EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#files where file_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#">)
			)
			</cfquery>
			<!--- If not we add it or else we simply update the ct db --->
			<cfif labhere.recordcount EQ 0>
				<cfset label_path_list = "">
				<cfset label_root_id=0>
				<!--- Get label's individually to insert in Labels table --->
				<cfloop list="#i#" delimiters="/" index="idx" >
					<!--- Create uuid --->
					<cfset theid = createuuid("")>
					<!--- Set Label path --->
					<cfset label_path_list = listappend(label_path_list,'#idx#','/')>
					<!--- Check if Label path already exists --->
					<cfset var checklabelpath = "">
					<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="checklabelpath">
					SELECT label_id, label_text, label_path
					FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
					WHERE label_path = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#label_path_list#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
					</cfquery>
					<!--- Insert only new labels --->
					<cfif checklabelpath.RecordCount EQ 0>
						<!--- Insert --->
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#labels
							(label_id, label_text, label_date, user_id, host_id, label_path, label_id_r)
							VALUES(
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">,
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#idx#">,
								<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.razuna.session.theuserid#">,
								<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">,
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#label_path_list#">,
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#label_root_id#">
							)
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Insert into CT --->
					<cfif idx EQ listLast(i,"/")>
						<cftransaction>
							<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
							INSERT INTO ct_labels
							(ct_label_id, ct_id_r, ct_type, rec_uuid)
							VALUES(
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.kind#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
							)
							</cfquery>
						</cftransaction>
					</cfif>
					<!--- Set Parent id --->
					<cfif checklabelpath.RecordCount NEQ 0>
						<cfset label_root_id = checklabelpath.label_id>
					<cfelse>
						<cfset label_root_id = theid>
					</cfif>
				</cfloop>
			<!--- Label is here --->
			<cfelse>
				<cftransaction>
					<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
					INSERT INTO ct_labels
					(ct_label_id, ct_id_r, ct_type, rec_uuid)
					VALUES(
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#labhere.label_id#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.kind#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
					)
					</cfquery>
				</cftransaction>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<!--- <cfset resetcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid)> --->
		<!--- Return --->
		<cfreturn  />
	</cffunction>

	<!---Import: Custom Fields ---------------------------------------------------------------------->
	<cffunction name="doimportcustomfields" output="false" returntype="void">
		<cfargument name="thestruct" type="struct">
		<cfargument name="assetid" type="string">
		<cfargument name="thecurrentRow" type="string">
		<!--- Param --->
		<cfset var doloop = false>
		<cfset var theid = "">
		<!--- Get the columlist --->
		<cfloop list="#arguments.thestruct.theimport.columnList#" delimiters="," index="i">
			<!--- If template --->
			<cfif arguments.thestruct.impp_template NEQ "">
				<cfloop query="arguments.thestruct.template.impval">
					<cfif imp_field EQ listfirst(i,":") AND !imp_key>
						<!--- <cfset var cfvalue = arguments.thestruct.theimport[i][arguments.thecurrentRow]> --->
						<cfset var theid = imp_map>
						<cfset var doloop = true>
					</cfif>
				</cfloop>
			<cfelseif i contains ":">
				<!--- The ID --->
				<cfset var theid = listLast(i,":")>
				<cfset var doloop = true>
			</cfif>
			<!--- Custom fields magic --->
			<cfif doloop>
				<!--- The value --->
				<cfset var cfvalue = ltrim(arguments.thestruct.theimport[i][arguments.thecurrentRow])>
				<!--- Insert or update --->
				<cfset var qry = "">
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
				SELECT v.cf_id_r, v.cf_value, f.cf_type
				FROM #arguments.thestruct.razuna.session.hostdbprefix#custom_fields_values v, #arguments.thestruct.razuna.session.hostdbprefix#custom_fields f
				WHERE v.cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				AND v.asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				AND v.cf_id_r = f.cf_id
				</cfquery>
				<!--- Make sure custom field id exists --->
				<cfset var iscf = "">
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="iscf">
				SELECT 1
				FROM #arguments.thestruct.razuna.session.hostdbprefix#custom_fields
				WHERE cf_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				</cfquery>

				 <!--- RAZ-2965: If custom field is found then do insert/update. This avoids database constraint errors --->
				 <cfif iscf.recordcount neq 0>
					<!--- Insert --->
					<cfif qry.recordcount EQ 0>
						<cftransaction>
							<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
							INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#custom_fields_values
							(cf_id_r, asset_id_r, cf_value, host_id, rec_uuid)
							VALUES(
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#cfvalue#">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">,
							<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
							)
							</cfquery>
						</cftransaction>
					<!--- Update --->
					<cfelse>
						<!--- If append --->
						<cfif arguments.thestruct.imp_write EQ "add" AND qry.cf_type NEQ "select">
							<cfif cfvalue NEQ "">
								<cfset var cfvalue = qry.cf_value & " " & cfvalue>
							<cfelse>
								<cfset var cfvalue = qry.cf_value>
							</cfif>
						</cfif>
						<cftransaction>
							<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
							UPDATE #arguments.thestruct.razuna.session.hostdbprefix#custom_fields_values
							SET cf_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cfvalue#">
							WHERE cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
							AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
							</cfquery>
						</cftransaction>
					</cfif>
				</cfif>
			</cfif>
			<!--- Param --->
			<cfset var doloop = false>
			<cfset var theid = "">
		</cfloop>
		<!--- Return --->
		<cfreturn  />
	</cffunction>

</cfcomponent>