import groovy.json.JsonSlurper;
json=new URL("http://nexus.local:8081/service/siesta/rest/beta/search/assets?repository=hello-world&group=hello-world&maven.extension=war").text
def parser = new JsonSlurper()
def result = parser.parseText(json)

List versions = new ArrayList()

result.items.path.each {
	versions.add(it[23..it.size()-1])
	}
versions.sort()
return versions 
