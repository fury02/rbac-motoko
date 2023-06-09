import { WEEK; DAY; HOUR; MINUTE; SECOND } "mo:time-consts";
module{
    //the validity period of the token (lifetime)
    public let count_minute = 30;//minute
    public let count_second = 5;//second    
    //token length (according to the standard)  
    public let length_bytes = 26; 
    //token lifetime from the moment of creation
    public let exp_regarding = 24; //WEEK; DAY; HOUR; MINUTE; SECOND
    public let exp_interval = HOUR;     
    //test token lifetime (100 second)
    public let exp_regarding_short = 100; //WEEK; DAY; HOUR; MINUTE; SECOND
    public let exp_interval_short = SECOND;                                                                           
};