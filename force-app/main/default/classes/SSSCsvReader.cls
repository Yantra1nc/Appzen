/**
* Used to read a delimited file.
*/
public class SSSCsvReader implements Iterator<String>, Iterable<String>{
    private String delim = ',';
    // the input data
    private List<String> buffer =  new List<String>();
    //splitter variables
    private String m_Data;
    private Integer m_index = 0;
    private String m_rowDelimiter = '\n';
    
    
    public SSSCsvReader(String data){
        //this.buffer = data.split('\n'); 
        m_Data = data;
        Iterator<String> iterator = this.iterator();
        while (iterator.hasNext()) {
            this.buffer.add(iterator.next());
        }
    }
    
    public SSSCsvReader(String data, String delim){
        m_Data = data;
        Iterator<String> iterator = this.iterator();
        while (iterator.hasNext()) {
            this.buffer.add(iterator.next());
        }
        this.delim = delim;
    }
    
    /**
* Read and parse next available line.  Return null if end of stream.
*/
    public String[] readLine(){
        if(buffer.size() == 0)
            return null;
        String line = this.buffer.remove(0);
        String[] parts = new String[] {};
            while(line != ''){
                Integer next = 0;
                if(line.startsWith('"')){
                    line = line.substring(1); // strip initial
                    Integer quoteIndex = findQuote(line, 0);
                    while(quoteIndex == -1){
                        if(buffer.size() == 0){
                            // EOT!
                            quoteIndex = line.length();
                        } else { 
                            // grab the next line
                            Integer skip = line.length();
                            line += '\n' + this.buffer.remove(0);
                            quoteIndex = findQuote(line, skip);
                        }
                    }
                    // advance to comma
                    next = quoteIndex + 1;
                    parts.add(line.substring(0, quoteIndex).replace('""', '"'));
                } else {
                    next = line.indexOf(this.delim, next);
                    if(next == -1)
                        next = line.length();
                    // NB in Substring, "endindex" is the index of the character AFTER the last index to get
                    parts.add(line.substring(0, next));
                }		
                if(next == line.length() - 1)
                    // case of a terminating comma.
                    parts.add('');
                line = next < line.length() ? line.substring(next+1) : '';
            }
        if(parts.size() == 0)
            // empty string - we still want to return something...
            parts.add('');
        return parts;
    }
    
    static private Pattern quotePattern = Pattern.compile('(?<!")"(?!")');
    /**
* Find next quote in the line
*/
    private Integer findQuote(String line, Integer skip){
        Matcher m = quotePattern.matcher(line);
        m.region(skip, m.regionEnd());
        if(!m.find())
            return -1;
        return m.start();
    }
    
    
    
    
    //custom iterator here to avoid too complicated regex error
      public SSSCsvReader(String fileData, String rowDelimiter, Boolean isSplitter) {
        m_Data = fileData; 
        m_rowDelimiter = rowDelimiter;
    }
    public Boolean hasNext() {
        return m_index < m_Data.length() ? true : false;
    }
    public String next() {     
        Integer key = m_Data.indexOf(m_rowDelimiter, m_index);
        
        if (key == -1)
            key = m_Data.length();
        
        String row = m_Data.subString(m_index, key);
        m_index = key + 1;
        return row;
    }
    public Iterator<String> Iterator() {
        return this;   
    }
}