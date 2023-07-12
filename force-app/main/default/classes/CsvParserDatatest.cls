public class CsvParserDatatest {
    public class wrappercls{
        String CustomerCode{get;set;}
        String CustomerName{get;set;}
        String ContactName{get;set;}
        String ContactEmail{get;set;}
        String ContactPhone{get;set;}
        String BillingAddressLine1{get;set;}
        String BillingAddressLine2{get;set;}
        String BillingAddressCity{get;set;}
        String BillingAddressState{get;set;}
        String BillingAddressCountry{get;set;}
        String BillingAddressPincode{get;set;}
        String BillingAddressPhone{get;set;}
        String ServiceTaxNumber{get;set;}
        String CSTNumber{get;set;}
        String ShippingAddressLine1{get;set;}
        String ShippingAddressLine2{get;set;}
        String ShippingAddressCity{get;set;}
        String ShippingAddressState{get;set;}
        String ShippingAddressCountry{get;set;}
        String ShippingAddressPincode{get;set;}
        String ShippingAddressPhone{get;set;}
    }
    public static void callParser(){
        String data = 'Customer Code,Customer Name,Contact Name,Contact Email,Contact Phone,Billing Address Line1,Billing Address Line2,Billing Address City,Billing Address State,Billing Address Country,Billing Address Pincode,Billing Address Phone,Service Tax Number,CST Number,Shipping Address Line1,Shipping Address Line2,Shipping Address City,Shipping Address State,Shipping Address Country,Shipping Address Pincode,Shipping Address Phone\n12345,abcde2,Test,test@uc.com,5647685743,Delhi,asdfgh,Gurgaon,TL,IN,110020,9999999999,,,Delhi,asdfgh,Gurgaon,TL,IN,110020,9999999999\n0,0,,,,janakpuri,,Delhi,DL,IN,110009,9658743210,,,janakpuri,,Delhi,DL,IN,110009,9658743210\n89545,abcde,,,,Delhi,,delhi,DL,IN,110020,9999999999,,,Delhi,,delhi,DL,IN,110020,9999999999\nsanju,sanjay,,,,okhla,phase-3,New Delhi,DL,IN,110020,9563214788,,,okhla,phase-3,New Delhi,DL,IN,110020,9563214788\npnt,pant,,,,janakpuri,C1,Delhi,DL,IN,110056,9874563217,,,janakpuri,C1,Delhi,DL,IN,110056,9874563217\n9662063,KISHAN,,,,"68,Ground floor",Okhla phase 3,NEW DELHI,DL,IN,110020,9898998989,,89876545678889,"68,Ground floor",Okhla phase 3,NEW DELHI,DL,IN,110020,9898998989\nbhau,Nikhil Bhau,,,,jgfuwgfufeg,,delhi,AS,IN,110020,875682652,,,jgfuwgfufeg,,delhi,AS,IN,110020,875682652\nNag1,Ngamani,,,,C-93,,New delhi,DL,IN,110092,9898989898,,,C-93,,New delhi,DL,IN,110092,9898989898\nTest,Test,,,,abc,,Pune,MH,IN,110010,9874562314,,,abc,,Pune,MH,IN,110010,9874562314\ndhar,dhar,dhar,dhar.yadav@gmail.com,9371973941,jfjsd,j,delhi,DL,IN,100001,9371973941,,,jfjsd,j,delhi,DL,IN,100001,9371973941\nyadav,dhar yadav,,,,dhar yadav,jassffaskg,Mumbai,MH,IN,401203,9371973941,,,dhar yadav,jassffaskg,Mumbai,MH,IN,401203,9371973941\nABCD,ABCD,Rahul,abcd@gmail.com,989889899898,Apple ,dshhdshew ,new delhi,DL,IN,110020,989898989898,,,Apple ,dshhdshew ,new delhi,DL,IN,110020,989898989898\npavanu,Pavan,Pavan,srinidhi.bk@unicommerce.com,8296454652,katwaria sarai,,delhi,DL,IN,110010,8296454652,,,katwaria sarai,,delhi,DL,IN,110010,8296454652\nSatyaa,Satya Test Customer,,,,xyz,abc,mumbai,MH,IN,400053,8861186611,,,xyz,abc,mumbai,MH,IN,400053,8861186611\nC-4185,Test Buyer,Test Buyer,purchases@wishbook.io,9916119362,test,,Bengaluru,KA,IN,560036,9916119362,,,test,,Bengaluru,KA,IN,560036,9916119362\nC-2241,Jay Dev,Jay Dev,jay@gmail.com,9925024856,tesat,,Bangalore,GJ,IN,523687,9925024856,,,tesat,,Bangalore,GJ,IN,523687,9925024856\nC-4059,Abc,Abc,purchases@wishbook.io,6554444444,"upper bazar , ranchi",,Bhiwani,HR,IN,834001,6554444444,,,"upper bazar , ranchi",,Bhiwani,HR,IN,834001,6554444444';
        SSSCsvReader obj = new SSSCsvReader(data);
        List<wrappercls> wrapObjlst = new List<wrappercls>();
        
        for(Integer i=1;i<data.split('\n').size();i++){
            wrappercls wrapObj = new wrappercls();
            String[] fields = obj.readLine();
            System.debug('--> '+fields);
            wrapObj.CustomerCode =  fields != null && fields.size() > 0 ? fields[0] : '';
            wrapObj.CustomerName =  fields != null && fields.size() > 1 ? fields[1] : '';
            wrapObj.ContactName=  fields != null && fields.size() > 2 ? fields[2] : '';
            wrapObj.ContactEmail =  fields != null && fields.size() > 3 ? fields[3] : '';
            wrapObj.ContactPhone =  fields != null && fields.size() > 4 ? fields[4] : '';
            wrapObj.BillingAddressLine1 =  fields != null && fields.size() > 5 ? fields[5] : '';
            wrapObj.BillingAddressLine2 =  fields != null && fields.size() > 6 ? fields[6] : '';
            wrapObj.BillingAddressCity =  fields != null && fields.size() > 7 ? fields[7] : '';
            wrapObj.BillingAddressState =  fields != null && fields.size() > 8 ? fields[8] : '';
            wrapObj.BillingAddressCountry = obj != null && fields != null && fields[9] != null && fields.size() > 9 ? fields[9] : '';
            wrapObj.BillingAddressPincode =  fields != null && fields.size() > 10 ? fields[10] : '';
            wrapObj.BillingAddressPhone =  fields != null && fields.size() > 11 ? fields[11] : '';
            wrapObj.ServiceTaxNumber =  fields != null && fields.size() > 12 ? fields[12] : '';
            wrapObj.CSTNumber =  fields != null && fields.size() > 13 ? fields[13] : '';
            wrapObj.ShippingAddressLine1 =  fields != null && fields.size() > 14 ? fields[14] : '';
            wrapObj.ShippingAddressLine2 =  fields != null && fields.size() > 15 ? fields[15] : '';
            wrapObj.ShippingAddressCity =  fields != null && fields.size() > 16 ? fields[16] : '';
            wrapObj.ShippingAddressState =  fields != null && fields.size() > 17 ? fields[17] : '';
            wrapObj.ShippingAddressCountry =  fields != null && fields.size() > 18 ? fields[18] : '';
            wrapObj.ShippingAddressPincode =  fields != null && fields.size() > 19 ? fields[19] : '';
            wrapObj.ShippingAddressPhone =  fields != null && fields.size() > 20 ? fields[20] : '';
            wrapObjlst.add(wrapObj);
        }
        for(wrappercls objo : wrapObjlst){
            System.debug('-> '+objo);
        }
    }
}