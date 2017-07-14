<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>redwing__Approved_Task_Alert</fullName>
        <description>Approved Task Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>redwing__LMS_Email_Templates/redwing__LearnTrac_Approved_Task_Notification</template>
    </alerts>
    <alerts>
        <fullName>redwing__Rejected_Task_Alert</fullName>
        <description>Rejected Task Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>redwing__LMS_Email_Templates/redwing__LearnTrac_Rejected_Task_Notification</template>
    </alerts>
    <rules>
        <fullName>redwing__Approved_Task_Notification</fullName>
        <actions>
            <name>redwing__Approved_Task_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>(PRIORVALUE( redwing__Approved__c ) != redwing__Approved__c) &amp;&amp; redwing__Approved__c &amp;&amp;  TEXT(redwing__Approval_Status__c) == &apos;Approved&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>redwing__Rejected_Task_Notification</fullName>
        <actions>
            <name>redwing__Rejected_Task_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>!redwing__Approved__c &amp;&amp; TEXT(PRIORVALUE(redwing__Approval_Status__c)) != TEXT(redwing__Approval_Status__c) &amp;&amp; TEXT(redwing__Approval_Status__c) == &quot;Rejected&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
