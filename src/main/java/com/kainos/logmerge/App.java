package com.kainos.logmerge;

import java.io.BufferedOutputStream;
import java.io.OutputStream;
import java.util.Random;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

public class App 
{
	static final Logger LOG = LoggerFactory.getLogger(App.class);
    public static void main( String[] args )
    {
    	
    	MDC.put("tenant", "T:tyco");
    	MDC.put("test-run", "TR:" + new Integer(new Random().nextInt(2000)));
    	MDC.put("tr-bp", "TRBP:" + new Integer(new Random().nextInt(3000)));
    	
    	Random generator = new Random();
    	Boolean i = true;
    	while(i) {
    		int rnd = generator.nextInt(100);
    		if(rnd < 70) {
    			LOG.info("info O_o");
    		} else if(rnd < 95) {
    			LOG.warn("warning :O");
    		} else {
    			try {
    				String t = "a";
    				t.charAt(6);
    			} catch(Exception e) {
//    				OutputStream os = new BufferedOutputStream(os);
    				LOG.error("error D:");
    				e.printStackTrace();
    			}
    		}
    		try {
				Thread.sleep(2000L);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
    	}
    	
    	MDC.clear();
    	
        //LOG.trace("Hello World!t");
        //LOG.debug("Hello World!d");
        
    }
}
