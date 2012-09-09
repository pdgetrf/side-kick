import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import java.io.File;

public class ReadXMLDispatch
{
	public static void main(String argv[]) 
	{
		try 
		{
			File fXmlFile = new File("c:\\specs.xml");
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(fXmlFile);
			doc.getDocumentElement().normalize();

			System.out.println("Root element :" + doc.getDocumentElement().getNodeName());
			NodeList nList = doc.getElementsByTagName("staff");
			System.out.println("-----------------------");

			for (int i = 0; i < nList.getLength(); i++) 
			{
				Node nNode = nList.item(i);
				if (nNode.getNodeType() == Node.ELEMENT_NODE) 
				{
					Element eElement = (Element) nNode;

					System.out.println("First Name : " + getTagValue("firstname", eElement));
					System.out.println("Last Name : " + getTagValue("lastname", eElement));
					System.out.println("Nick Name : " + getTagValue("nickname", eElement));
					System.out.println("Salary : " + getTagValue("salary", eElement));
				}
			}
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}
	}

	private static String getTagValue(String sTag, Element eElement) 
	{
		NodeList nlList = eElement.getElementsByTagName(sTag).item(0).getChildNodes();

		Node nValue = (Node) nlList.item(0);

		return nValue.getNodeValue();
	}
}
