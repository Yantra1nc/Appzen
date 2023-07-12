trigger ContactActive on User (after insert, after Update) {
    List<Id> userIds=new List<Id>();
    
    For(User u:Trigger.new){
        if(u.ContactId != null){
            userIds.add(u.Id);
        }
    }
    if(!userIds.isEmpty() && userIds!=NULL){
        ContactActiveHandler.updateUserContact(userIds);
    }
}