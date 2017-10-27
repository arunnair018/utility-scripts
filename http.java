import java.net.*;
import java.io.*;

public class http {
	public static void main(String args[]) throws Exception{
        // URL ip = new URL("http://checkip.amazonaws.com");
        URL ip = new URL("http://www.amazon.com");
    	URLConnection conn = ip.openConnection();
    	String h1=conn.getURL();
    	System.out.println(h1);
		try {
	     InputStream in = new BufferedInputStream(conn.getInputStream());
	     InputStreamReader isr = new InputStreamReader(in);
	     BufferedReader br = new BufferedReader(isr);
	 	 System.out.println(br.read());
	 	 System.out.println(in);

	 	}
	 	finally{
	 	}
	}
/*
	public static void main(String args[]){
		
		HttpClient httpclient = new DefaultHttpClient();
		HttpPost httpPost = new HttpPost("https://seraph.karunya.edu:1003");
	   	//Arun
	    String urlString = "https://seraph.karunya.edu:1003"; // URL to call

		JSONObject jsonObject = new JSONObject();
		jsonObject.accumulate("username", "UR14CS214");
		jsonObject.accumulate("magic", magic);
		jsonObject.accumulate("password", "cheetah214");
	    String data =  jsonObject.toString(); //data to post

		StringEntity se = new StringEntity(json);
		httpPost.setEntity(se);
		httpPost.setHeader("Accept", "application/json");
		httpPost.setHeader("Content-type", "application/json");
		HttpResponse httpResponse = httpclient.execute(httpPost);
		inputStream = httpResponse.getEntity().getContent();


	    OutputStream out = null;
	    try {

	        URL url = new URL(urlString);

	        HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();

	        out = new BufferedOutputStream(urlConnection.getOutputStream());

	        BufferedWriter writer = new BufferedWriter (new OutputStreamWriter(out, "UTF-8"));

	        writer.write(data);

	        writer.flush();

	        writer.close();

	        out.close();

	        urlConnection.connect();


	    } catch (Exception e) {
	        System.out.println(e.getMessage());
	    }

        }
*/
}