// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import ballerina/http;
import ballerina/log;

const X_JWT_ASSERTION = "x-jwt-assertion";
const EMAIL = "email";

# Request Interceptor used to decode the JWT.
service class JwtInterceptor {
    *http:RequestInterceptor;
    isolated resource function 'default [string... path](http:RequestContext ctx, http:Request req)
    returns http:NextService|http:NotFound|http:Unauthorized|http:Forbidden|error? {

        if req.method == http:OPTIONS {
            return ctx.next();
        }
        string|error jwtAssertion = req.getHeader(X_JWT_ASSERTION);

        if jwtAssertion is error {
            log:printError("Error in jwt assertion", jwtAssertion, 'info = jwtAssertion.toString());
            return http:UNAUTHORIZED;
        }

        JwtPayload|error jwtInfo = jwtDecoder(jwtAssertion);
        if jwtInfo is error {
            log:printError("Error while decoding JWT", jwtInfo, 'info = jwtInfo.toString());
            return http:UNAUTHORIZED;
        }
        if isEmptyVal(jwtInfo.email) {
            log:printWarn("Email is empty in the JWT", 'info = jwtInfo.toString());
            return http:UNAUTHORIZED;
        }

        ctx.set(EMAIL, jwtInfo.email);
        return ctx.next();
    }
}
