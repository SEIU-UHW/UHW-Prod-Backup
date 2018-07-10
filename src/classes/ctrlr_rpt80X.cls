public class ctrlr_rpt80X{

    public string turfJSON{get; set;}

    public string userJSON{get; set;}

    public string ecomJSON{get; set;}

    public ctrlr_rpt80X(){
        //get some user info
        string userId = UserInfo.getUserId();
        string query_user = 'SELECT ID, Name, Division, Title from User WHERE Id = :userId';

        List<User> user_result = Database.query(query_user);
        userJSON = JSON.serialize(user_result);

        //get a mapping of Constituency Seat to EComm Member
        string query_ecomm = 'select FID__c, Account.District_2017__r.ConstituencyName__c from Contact where Executive_Body_Title__c = \'Executive Committee\' ';
        List<sObject> ecom_result = Database.query(query_ecomm);
        ecomJSON = JSON.serialize(ecom_result);

        //get the turf for kaiser and hospital
        string query_turf = 'select Id, Name, Employer_Id__c, Region__c, Account_Group__c, Regional_Director__r.Name, Coordinator__r.Name, Organizer_1__r.Name, District_2017__r.Name, Constituency__r.ConstituencyName__c, Hospital_System__c, BU_Count__c, Phase_6_Picket__c, Executive_Committee__c from Account where MO_Active__c = true AND (NOT Name like \'pomona valley%\') AND ( Account_Group__c in (\'KAISER\',\'HOSPITAL\')) AND Regional_Director__c != null AND Regional_Director__r.Name != \'jason capell\' ';
                                        
        List<sObject> turf_result = Database.query(query_turf);
        turfJSON = JSON.serialize(turf_result);

    }

    //BASIC STRAIGHT FORWARD QUERY (MUST BE < 15 MB DATASET)
    @RemoteAction
    public static List<sObject> getData(string query){    
        return Database.query(query);
    }

    //PARTITIONED QUERY FOR > 15 MB DATASETS
    @RemoteAction 
    public static List<sObject> getRecords(Id offsetId,string query) {        
        if(offsetId!=null) {
            //should check for WHERE before assuming but I'll get to that [TODO] later
            query += ' AND ID > :offsetId ';
        }
        query += ' ORDER BY Id ASC LIMIT 2000 ';
        return Database.query(query);
    }
}