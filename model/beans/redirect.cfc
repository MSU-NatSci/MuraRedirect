component
    extends="mura.bean.beanORM"
    table="muraredirect"
    entityname="redirect"
    bundleable="false"
    displayname="RedirectBean"
    public=false
    orderby="sourcePathValue,sourceDomainValue" {

    // primary key
    property name="redirectId" fieldtype="id";

    // attributes
    property name="siteID" datatype="varchar" length="255" required=true
        message="The siteID is required";
    property name="sourceProtocolValue" datatype="varchar" length="255";
    property name="sourceDomainValue" datatype="varchar" length="255";
    property name="sourceDomainRegexp" datatype="boolean" default=0;
    property name="sourcePathValue" datatype="varchar" length="255";
    property name="sourcePathRegexp" datatype="boolean" default=0;
    property name="targetURL" datatype="varchar" length="255" required=true
        message="The targetURL is required";
    property name="statusCode" datatype="int" validate="numeric" default="301";
    property name="hitCount" datatype="int" validate="numeric" default=0;
    property name="lastHit" datatype="datetime";
    property name="countStart" datatype="datetime";
    property name="enabled" datatype="boolean" default=1;
    property name="notes" datatype="text";
    property name="createdOn" datatype="datetime";
    property name="updatedOn" datatype="datetime";
    property name="updatedBy" datatype="varchar" length="255";

    // Custom Methods
}
