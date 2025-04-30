public without sharing class DoctorDataController {
    @AuraEnabled(cacheable=true)
    public static List<DoctorDataWrapper> getDoctorMetrics(String name) {
        List<DoctorDataWrapper> result = new List<DoctorDataWrapper>();
        
        // Query data from Data Cloud (DLM Object)
        List<Vet_Reports__dlm > doctorRecords = [SELECT Date__c, Patients__c, Feedback__c FROM Vet_Reports__dlm  where DoctorName__c =: name and date__c >= TODAY and date__c <= NEXT_N_DAYS:6];
        
        for (Vet_Reports__dlm  record : doctorRecords) {
            result.add(new DoctorDataWrapper(
                record.Date__c,
            record.Patients__c,
            record.Feedback__c
                ));
        }
        return result;
    }
    
    public class DoctorDataWrapper {
        @AuraEnabled public String dateOfCapture;
        @AuraEnabled public Decimal patientCount;
        @AuraEnabled public Decimal feedbackScore;
        
        public DoctorDataWrapper(Date dateOfCapture, Decimal patientCount, Decimal feedbackScore) {
            this.dateOfCapture =(String) dateOfCapture.format();
            this.patientCount = patientCount;
            this.feedbackScore = feedbackScore;
        }
    }


    @AuraEnabled(Cacheable=true)
    public static List<String> getDayCareCenters()
    {
        List<String> namesString = new List<String>();
        for(Daycare_Center__c d : [Select id, Name from Daycare_Center__c])
        {
            namesString.add(d.Name);
        }
        return namesString;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Map<String,Object>> getEachDayCareCenter(String dcname){
        try {   
                List<Map<String,Object>> lst= new List<Map<String,Object>>();
                Map<String,Object> eachDc = new Map<String,Object>();
                for(Daycare_Center__c dc : [Select id,Location__Latitude__s,Location__Longitude__s,Name,Address__c from Daycare_Center__c where Name =: dcname])
                {
                    Map<String, Object> locationMap = new Map<String, Object>();
                    locationMap.put('Latitude', String.valueOf(dc.Location__Latitude__s));
                    locationMap.put('Longitude', String.valueOf(dc.Location__Longitude__s));
        
                    Map<String, Object> resultMap = new Map<String, Object>();
                    resultMap.put('location', locationMap);
                    resultMap.put('title', dc.Name);
                    resultMap.put('description', dc.Address__c);
                    lst.add(resultMap);
                }

                return lst;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}