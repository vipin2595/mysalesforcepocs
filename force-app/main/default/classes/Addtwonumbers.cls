public class Addtwonumbers {
    public integer aval{set;get;}
    public integer bval{set;get;}
    public integer cval{set;get;}
    public void ADD(){
        cval=aval+bval;
    }
    public void reset(){
        aval=null;
        bval=null;
        cval=null;
    }

}