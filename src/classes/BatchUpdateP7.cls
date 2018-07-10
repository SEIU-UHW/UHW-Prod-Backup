global class BatchUpdateP7 Implements Schedulable{
    global void execute(SchedulableContext sc){
        setToActive();
    }
    
    public void setToActive(){
        List<Contact> updateContacts = new List<Contact>();
        List<String> survey_codes = new List<String>();
        List<BatchUpdateP7_CODELIST__c> scs = BatchUpdateP7_CODELIST__c.getall().values();
        //Map<String_dataset_name, CustomSettingName__c> mcs = CustomSettingName__c.getAll();
        //BatchUpdateP7_CODELIST__c scs = BatchUpdateP7_CODELIST__c.getValues();
        for (BatchUpdateP7_CODELIST__c sc :scs){
            String this_code = String.ValueOf(sc.Name);
            system.debug(this_code);
            survey_codes.add(this_code);
        }
        for (AggregateResult ar:[Select Contact__c From Survey_Response__c Where Survey_Code__c IN:survey_codes AND Contact__r.X80_P7_Active__c=false AND Contact__c != null Group By Contact__c]){        
            Contact c = new Contact();
            //system.debug(ar.get('Contact__c'));
            String cid = ar.get('Contact__c').toString();
            c.Id = cid;
            c.X80_P7_Active__c = true;    
            updateContacts.add(c);    
        }
        Database.update(updateContacts);
    }
    private static string schedStringToTime(String schedString){
        string twodigitHour = schedString.right(8).substring(0,2);
        integer tdh = integer.valueof(twodigitHour);
        string finalTime = twodigitHour;
        string ampm = 'AM';
        if(tdh >= 12){
            ampm = 'PM';
        }
        if(twodigitHour == '00'){
            finalTime = '12';
        } else if (tdh <= 12){
            finalTime = twodigitHour;
        } else{
            integer tt = tdh - 12;
            finalTime = String.valueOf(tt);
        }
        finalTime = finalTime + ampm;
        return finalTime;
    }
    public static String sched = '0 0 00 ? * *';  //EveryDay, 12AM
    // used for scheduling a repeating job - currently set for 12AM Daily.
    global static String scheduleMe(String schedString) {                       
        if(String.isBlank(schedString)){
            schedString = sched;            
        }
        string timeName = ' - ' + schedStringToTime(schedString);        
        BatchUpdateP7 dailyActive = new BatchUpdateP7();
        return System.schedule('Schedule P7UpdateActive' + timeName, schedString,dailyActive);
    }

}