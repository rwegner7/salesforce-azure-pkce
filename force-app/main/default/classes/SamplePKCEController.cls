public class SamplePKCEController {

    public String resp { get; set; } //get resp from vf page

    public PageReference setResponse(){
        System.debug('$$$ response passed ' + resp);
        return null;
    }
}