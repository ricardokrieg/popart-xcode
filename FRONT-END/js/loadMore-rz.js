/*>-----------------------------
----------> Load More <---------
------> DIV IMAGES POST <-------
----------> Gallrey <-----------
--------------------------------
------> Md.Rashiduzzaman <------
----------> 23/10/2015 <--------
-----------------------------<*/

$(window).load(function(){
	var n,i,t,b,o;
	n=8;
	i=$("#rz-loaderItems>div.rz-item").length;
	t=i+n;b=t-i;o=b-1;
	$("div.rz-item:lt("+b+")").css("display","block");
	$("div.rz-item:gt("+o+")").css("display","none");
	$("div.rz-item:lt("+b+")").addClass("rz-loaded");
});
$(window).scroll(function(){
	var l,t,i;
	l=$("div.rz-loaded").length;
	t=$("div.rz-item").length;
	i=l+8;
	if($(window).scrollTop()==$(document).height()-$(window).height()){
		$("div.rz-item:lt("+i+")").css("display","block");
		$("div.rz-item:lt("+i+")").addClass("rz-loaded");
		if(l!=t){
			$('div#rz-loader').html("<center><img src='images/loader.gif'/></center>");
		}else{
			$('div#rz-loader').html("<p>No More Images</p>");
		}
	}
});