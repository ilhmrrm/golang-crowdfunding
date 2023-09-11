[1mdiff --git a/auth/service.go b/auth/service.go[m
[1mindex b73b9ad..73ae9a1 100644[m
[1m--- a/auth/service.go[m
[1m+++ b/auth/service.go[m
[36m@@ -11,7 +11,8 @@[m [mtype Service interface {[m
 	ValidateToken(token string) (*jwt.Token, error)[m
 }[m
 [m
[31m-type jwtService struct{}[m
[32m+[m[32mtype jwtService struct {[m
[32m+[m[32m}[m
 [m
 var SECRET_KEY = []byte("BWASTARTUP_s3cr3T_k3Y")[m
 [m
[1mdiff --git a/handler/user.go b/handler/user.go[m
[1mindex 4f7fa3a..f2b0c88 100644[m
[1m--- a/handler/user.go[m
[1m+++ b/handler/user.go[m
[36m@@ -92,7 +92,7 @@[m [mfunc (h *userHandler) Login(c *gin.Context) {[m
 	c.JSON(http.StatusOK, response)[m
 }[m
 [m
[31m-func (h *userHandler) CheckEmailAvailibility(c *gin.Context) {[m
[32m+[m[32mfunc (h *userHandler) CheckEmailAvailability(c *gin.Context) {[m
 	var input user.CheckEmailInput[m
 [m
 	err := c.ShouldBindJSON(&input)[m
[36m@@ -128,25 +128,33 @@[m [mfunc (h *userHandler) CheckEmailAvailibility(c *gin.Context) {[m
 }[m
 [m
 func (h *userHandler) UploadAvatar(c *gin.Context) {[m
[32m+[m	[32m// catch input from user[m
[32m+[m	[32m// simpan gambar di folder "images/"[m
[32m+[m	[32m// di service kita panggil repo[m
[32m+[m	[32m//  JWT (sementara hardcode, seakan" user yang login id = 1)[m
[32m+[m	[32m//  repo ambil data user yangh ID 1[m
[32m+[m	[32m// repo update data user simpan lokasi file[m
 [m
 	file, err := c.FormFile("avatar")[m
 	if err != nil {[m
 		data := gin.H{"is_uploaded": false}[m
[31m-		response := helper.APIResponse("failed to upload avatar image", http.StatusBadRequest, "error", data)[m
[32m+[m		[32mresponse := helper.APIResponse("Failed to upload avatar image 1", http.StatusBadRequest, "error handler 1", data)[m
 [m
 		c.JSON(http.StatusBadRequest, response)[m
 		return[m
 	}[m
 [m
[31m-	// harusnya dapat dari JWT, but next time[m
[31m-	userID := 1[m
[32m+[m	[32m// harusnya dapet dari JWT, but next time[m
[32m+[m	[32mcurrentUser := c.MustGet("currentUser").(user.User)[m
[32m+[m	[32muserID := currentUser.ID[m
 [m
[32m+[m	[32m// file would be save on images folder[m
 	path := fmt.Sprintf("images/%d-%s", userID, file.Filename)[m
 [m
 	err = c.SaveUploadedFile(file, path)[m
 	if err != nil {[m
 		data := gin.H{"is_uploaded": false}[m
[31m-		response := helper.APIResponse("failed to upload avatar image", http.StatusBadRequest, "error", data)[m
[32m+[m		[32mresponse := helper.APIResponse("Failed to upload avatar image 2", http.StatusBadRequest, "error handler 2", data)[m
 [m
 		c.JSON(http.StatusBadRequest, response)[m
 		return[m
[36m@@ -155,14 +163,14 @@[m [mfunc (h *userHandler) UploadAvatar(c *gin.Context) {[m
 	_, err = h.userService.SaveAvatar(userID, path)[m
 	if err != nil {[m
 		data := gin.H{"is_uploaded": false}[m
[31m-		response := helper.APIResponse("failed to upload avatar image", http.StatusBadRequest, "error", data)[m
[32m+[m		[32mresponse := helper.APIResponse("Failed to upload avatar image 3", http.StatusBadRequest, "error handler 3", data)[m
 [m
 		c.JSON(http.StatusBadRequest, response)[m
 		return[m
 	}[m
 [m
 	data := gin.H{"is_uploaded": true}[m
[31m-	response := helper.APIResponse("Avatar succesfully uploaded", http.StatusOK, "success", data)[m
[32m+[m	[32mresponse := helper.APIResponse("Avatar successfuly uploaded", http.StatusOK, "success", data)[m
 [m
 	c.JSON(http.StatusOK, response)[m
 }[m
[1mdiff --git a/main.go b/main.go[m
[1mindex 9bd9640..bb5895a 100644[m
[1m--- a/main.go[m
[1m+++ b/main.go[m
[36m@@ -3,10 +3,14 @@[m [mpackage main[m
 import ([m
 	"golang-crowdfunding/auth"[m
 	"golang-crowdfunding/handler"[m
[32m+[m	[32m"golang-crowdfunding/helper"[m
 	"golang-crowdfunding/user"[m
 	"log"[m
[32m+[m	[32m"net/http"[m
[32m+[m	[32m"strings"[m
 [m
 	"github.com/gin-gonic/gin"[m
[32m+[m	[32m"github.com/golang-jwt/jwt"[m
 	"gorm.io/driver/mysql"[m
 	"gorm.io/gorm"[m
 )[m
[36m@@ -30,7 +34,53 @@[m [mfunc main() {[m
 [m
 	api.POST("/users", userHandler.RegisterUser)[m
 	api.POST("/sessions", userHandler.Login)[m
[31m-	api.POST("/email_checkers", userHandler.CheckEmailAvailibility)[m
[31m-	api.POST("/avatars", userHandler.UploadAvatar)[m
[32m+[m	[32mapi.POST("/email_checkers", userHandler.CheckEmailAvailability)[m
[32m+[m	[32mapi.POST("/avatars", authMiddleware(authService, userService), userHandler.UploadAvatar)[m
 	router.Run()[m
 }[m
[32m+[m
[32m+[m[32mfunc authMiddleware(authService auth.Service, userService user.Service) gin.HandlerFunc {[m
[32m+[m
[32m+[m	[32mreturn func(c *gin.Context) {[m
[32m+[m		[32mauthHeader := c.GetHeader("Authorization")[m
[32m+[m
[32m+[m		[32mif !strings.Contains(authHeader, "Bearer") {[m
[32m+[m			[32mresponse := helper.APIResponse("Unauthorized", http.StatusUnauthorized, "Error From Bearer", nil)[m
[32m+[m			[32mc.AbortWithStatusJSON(http.StatusUnauthorized, response)[m
[32m+[m			[32mreturn[m
[32m+[m		[32m}[m
[32m+[m		[32m// Bearer tokentokentoken[m
[32m+[m		[32mtokenString := ""[m
[32m+[m		[32marrayToken := strings.Split(authHeader, " ")[m
[32m+[m
[32m+[m		[32mif len(arrayToken) == 2 {[m
[32m+[m			[32mtokenString = arrayToken[1][m
[32m+[m		[32m}[m
[32m+[m
[32m+[m		[32mtoken, err := authService.ValidateToken(tokenString)[m
[32m+[m		[32mif err != nil {[m
[32m+[m			[32mresponse := helper.APIResponse("Unauthorized", http.StatusUnauthorized, "Error From Tokenstring", nil)[m
[32m+[m			[32mc.AbortWithStatusJSON(http.StatusUnauthorized, response)[m
[32m+[m			[32mreturn[m
[32m+[m		[32m}[m
[32m+[m
[32m+[m		[32mclaim, ok := token.Claims.(jwt.MapClaims)[m
[32m+[m
[32m+[m		[32mif !ok || !token.Valid {[m
[32m+[m			[32mresponse := helper.APIResponse("Unauthorized", http.StatusUnauthorized, "Error From Claim", nil)[m
[32m+[m			[32mc.AbortWithStatusJSON(http.StatusUnauthorized, response)[m
[32m+[m			[32mreturn[m
[32m+[m		[32m}[m
[32m+[m
[32m+[m		[32muserID := int(claim["user_id"].(float64))[m
[32m+[m
[32m+[m		[32muser, err := userService.GetUserByID(userID)[m
[32m+[m		[32mif err != nil {[m
[32m+[m			[32mresponse := helper.APIResponse("Unauthorized", http.StatusUnauthorized, "Error From user_id", nil)[m
[32m+[m			[32mc.AbortWithStatusJSON(http.StatusUnauthorized, response)[m
[32m+[m			[32mreturn[m
[32m+[m		[32m}[m
[32m+[m
[32m+[m		[32mc.Set("currentUser", user)[m
[32m+[m	[32m}[m
[32m+[m[32m}[m
[1mdiff --git a/user/input.go b/user/input.go[m
[1mindex 9fa19cc..6250d19 100644[m
[1m--- a/user/input.go[m
[1m+++ b/user/input.go[m
[36m@@ -13,5 +13,5 @@[m [mtype LoginInput struct {[m
 }[m
 [m
 type CheckEmailInput struct {[m
[31m-	Email string `json:"email" binding:"required"`[m
[32m+[m	[32mEmail string `json:"email" binding:"required,email"`[m
 }[m
[1mdiff --git a/user/repository.go b/user/repository.go[m
[1mindex d220fcd..eaa131b 100644[m
[1m--- a/user/repository.go[m
[1m+++ b/user/repository.go[m
[36m@@ -48,7 +48,7 @@[m [mfunc (r *repository) FindByID(ID int) (User, error) {[m
 }[m
 [m
 func (r *repository) Update(user User) (User, error) {[m
[31m-	err := r.db.Save(user).Error[m
[32m+[m	[32merr := r.db.Save(&user).Error[m
 	if err != nil {[m
 		return user, err[m
 	}[m
[1mdiff --git a/user/service.go b/user/service.go[m
[1mindex b7f07fc..9d15452 100644[m
[1m--- a/user/service.go[m
[1m+++ b/user/service.go[m
[36m@@ -11,6 +11,7 @@[m [mtype Service interface {[m
 	Login(input LoginInput) (User, error)[m
 	IsEmailAvailable(input CheckEmailInput) (bool, error)[m
 	SaveAvatar(ID int, fileLocation string) (User, error)[m
[32m+[m	[32mGetUserByID(ID int) (User, error)[m
 }[m
 [m
 type service struct {[m
[36m@@ -96,3 +97,16 @@[m [mfunc (s *service) SaveAvatar(ID int, fileLocation string) (User, error) {[m
 [m
 	return updatedUser, nil[m
 }[m
[32m+[m
[32m+[m[32mfunc (s *service) GetUserByID(ID int) (User, error) {[m
[32m+[m	[32muser, err := s.repository.FindByID(ID)[m
[32m+[m	[32mif err != nil {[m
[32m+[m		[32mreturn user, err[m
[32m+[m	[32m}[m
[32m+[m
[32m+[m	[32mif user.ID == 0 {[m
[32m+[m		[32mreturn user, errors.New("No user found with that ID")[m
[32m+[m	[32m}[m
[32m+[m
[32m+[m	[32mreturn user, nil[m
[32m+[m[32m}[m
