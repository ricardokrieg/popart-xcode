$(function(){
	$('.bar a.mt').on('click', function(){
		$(this).siblings('ul').slideToggle();
	});
	//$('#datetimepicker1').datetimepicker();
	$('.general-flip').on('click', function(e){
		$('.general-content').slideToggle();
		$('.general-flip>p>span').toggleClass("glyphicon-triangle-top");
	});
});

// When the document is ready
$(document).ready(function () {
	
	$('#example1').datepicker({
		format: "dd/mm/yyyy"
	});  
});
var element = document.getElementById('footer');
var height = element.offsetHeight;
document.getElementById('wrap').style.paddingBottom = height + 'px';



 
