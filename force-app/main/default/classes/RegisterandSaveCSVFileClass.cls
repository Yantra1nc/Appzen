public class RegisterandSaveCSVFileClass{}

/*public class RegisterandSaveCSVFileClass 
{
    public Project__c newProject {get; set;}
    public Attachment attachment {get;set;}    
    public RegisterandSaveCSVFileClass(){
        newProject = new Project__c();
        attachment = new Attachment();
    }
    public void saveButtonAction(){
        System.debug('newProject.Name'+newProject.Name);
        if(newProject.Name != null){
            insert newProject;               
            if(attachment.Name.endsWith('.csv')){
                attachment.parentid = newProject.id;
                insert attachment;                
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'You need to upload only CSV document');
                ApexPages.addMessage(myMsg); 
                return ;
            }
        }
    }    
    
    

} */